require 'book_preview_uploader'

class Book < ActiveRecord::Base
  acts_as_taggable

  PREVIEW_WIDTH = 200
  PREVIEW_HEIGHT = 314
#  has_attached_file :preview, :url => "file://#{Mangar.mangar_dir}/system/:attachment/:id/:style/:filename", :path => "#{Mangar.mangar_dir}/system/:attachment/:id/:style/:filename", :styles => { :medium => "200>" }, :default_style => :medium
#  has_attached_file :preview, :path => "#{Mangar.mangar_dir}/system/:attachment/:id/:style/:filename", :styles => { :medium => "200>" }, :default_style => :medium

  mount_uploader :preview, BookPreviewUploader

  #default_scope :order => 'published_on DESC'

  def real_path
    File.expand_path("#{Mangar.dir}/#{path}")
  end

  def open
    increment!(:opens)
    update_attribute(:last_opened_at, DateTime.now)
    
    if File.video?(self.path)
      apps, background = ["gnome-mplayer", "mplayer"], false
    else
      if RUBY_PLATFORM =~ /darwin/
        apps, background = ["open -a /Applications/Xee.app/Contents/MacOS/Xee"], false
      elsif RUBY_PLATFORM =~ /linux/
        apps, background = ["comix -f", "geeqie -f", "gqview -f", "eog"], true
      end
    end

    apps.detect { |app| system("#{app} #{File.escape_name(real_path)} #{background ? '&' : ''}") }
  end

  def delete_original
    `rm -rf #{File.escape_name(real_path)}`
  end

  COMPRESSED_FILE_EXTENSIONS = %w(.zip .rar .cbz .cbr)
  ZIP_EXTENSIONS = %w(.zip .cbz)
  RAR_EXTENSIONS = %w(.rar .cbr)
  
  INTERESTING_EXTENSIONS = COMPRESSED_FILE_EXTENSIONS + File::VIDEO_EXTENSIONS

  #Iterate recursively over all files/dirs
  #If current item is a zip/rar/cbr/cbz file, pull out first image and store zip filename as manga name and zip filename as filename to load.
  #Else if current item is a dir, and it contains images but no directories, store the dir name as the manga name as well as the load filename.
  #Else skip/recurse into dir.
  def self.import_and_update
    #Requires GNU find 3.8 or above
    cmd = <<-CMD
cd #{File.escape_name(Mangar.dir)} && find . -type d -o \\( -type f \\( #{INTERESTING_EXTENSIONS.map { |ext| "-iname '*#{ext}'" }.join(' -o ')} \\) \\)
CMD

    $stdout.puts #This makes it actually import; fuck knows why

    path_list = IO.popen(cmd) { |s| s.read }

    path_list = path_list.split("\n").map { |e| e.gsub(/^\.\//, '') }.reject { |e| e[0, 1] == '.' }

    existing_books = Book.all
    existing_books.each do |book|
      unless path_list.include?(book.path)
        book.destroy
        existing_books.delete(book)
      end
    end

    (path_list - existing_books.map(&:path)).each { |path| self.import(path) }
  end

  def self.import(relative_path)
    real_path = File.expand_path("#{Mangar.dir}/#{relative_path}")

    begin
      raise "Won't be able to read #{real_path}" unless File.readable?(real_path)

      first_image_io, page_count = if File.video?(real_path)
        data_from_video_file(real_path)
      elsif COMPRESSED_FILE_EXTENSIONS.include?(File.extname(real_path))
        data_from_compressed_file(real_path)
      else
        data_from_directory(real_path)
      end
    rescue Exception => e
      ActionDispatch::ShowExceptions.new(Mangar::Application.instance).send(:log_error, e)
      return
    end
    
    return if first_image_io.nil?

    Book.create!(:title => File.basename(real_path).gsub(/_/, ' ').gsub(/#{INTERESTING_EXTENSIONS.map { |e| Regexp.escape(e) }.join('|')}$/, ''),
     :path => relative_path, :published_on => File.mtime(real_path), :preview => first_image_io,
      :pages => page_count)
  end

  def self.data_from_video_file(real_filename)
    frame_filename = "#{Dir.tmpdir}/#{ActiveSupport::SecureRandom.hex(20)}"
    system("totem-video-thumbnailer -r #{File.escape_name(real_filename)} #{File.escape_name(frame_filename)}")
    raise "Couldn't thumbnail #{real_filename}" unless File.exists?(frame_filename)
    at_exit { File.delete(frame_filename) if File.exists?(frame_filename) }

    return File.open(frame_filename, "r"), 1
  end

  def self.data_from_compressed_file(real_filename)
    #TODO: We move the file data around like a million times, we ought to be able to pass the input stream
    #directly from the zip file to the model or whatever
    first_image_str = ""
    filenames = []
    
    first_image_io = nil
    
    if ZIP_EXTENSIONS.include?(File.extname(real_filename))
      require 'zip/zip'
      zf = Zip::ZipFile.open(real_filename)
      filenames = zf.entries.map(&:name)
      
      first_image_filename = get_first_file(filenames)
      return nil, 0 if first_image_filename.nil?

      first_image_io = zf.get_input_stream(first_image_filename)
    elsif RAR_EXTENSIONS.include?(File.extname(real_filename))
      #TODO: Very hacky, relies on compatible unrar binary
      filenames = IO.popen("cd #{File.escape_name(Mangar.dir)} && unrar vb #{File.escape_name(real_filename)}") { |s| s.read }
      filenames = filenames.split("\n")
      
      first_image_filename = get_first_file(filenames)
      return nil, 0 if first_image_filename.nil?

      first_image_io = IO.popen("cd #{File.escape_name(Mangar.dir)} && unrar p -inul #{File.escape_name(real_filename)} #{File.escape_name(first_image_filename)}")
    end
    
    return nil, 0 if filenames.nil?
    
    #Bullshit time
    out_io = StringIO.new(first_image_io.read)
    out_io.instance_eval do
      def original_filename
        @original_filename ||= ActiveSupport::SecureRandom.hex(20)
      end
    end
    
    return out_io, filenames.count { |f| File.image?(f) }
  end

  #dir should be findable from CWD or absolute; no trailing slash
  def self.data_from_directory(real_dir)
    filenames = Dir.entries(real_dir)

    first_image_filename = get_first_file(filenames)
    return nil, 0 if first_image_filename.nil?

    return File.new("#{real_dir}/#{first_image_filename}", "r"), filenames.count { |f| File.image?(f) }
  end

  def self.reprocess
    Book.all.each do |book|
      real_path = File.expand_path("#{Mangar.dir}/#{book.path}")
    
      first_image_io, page_count = if COMPRESSED_FILE_EXTENSIONS.include?(File.extname(real_path))
        data_from_compressed_file(real_path)
      else
        data_from_directory(real_path)
      end
    
      next if first_image_io.nil?

      book.update_attribute(:preview, first_image_io)
    end
  end

  def self.get_first_file(file_list)
    file_list.reject { |e| e[0, 1] == '.' || !File.image?(e) }.sort.first
  end
end