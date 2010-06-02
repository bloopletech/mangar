require 'book_preview_uploader'

class Book < ActiveRecord::Base
  acts_as_taggable

#  has_attached_file :preview, :url => "file://#{MANGAR_DIR}/system/:attachment/:id/:style/:filename", :path => "#{MANGAR_DIR}/system/:attachment/:id/:style/:filename", :styles => { :medium => "200>" }, :default_style => :medium
#  has_attached_file :preview, :path => "#{MANGAR_DIR}/system/:attachment/:id/:style/:filename", :styles => { :medium => "200>" }, :default_style => :medium

  mount_uploader :preview, BookPreviewUploader

  default_scope :order => 'published_on DESC'

  def real_path
    File.expand_path("#{DIR}/#{path}")
  end

  def open
    increment!(:opens)
    update_attribute(:last_opened_at, DateTime.now)

    if RUBY_PLATFORM =~ /darwin/
      apps, background = ["open -a /Applications/Xee.app/Contents/MacOS/Xee"], false
    elsif RUBY_PLATFORM =~ /linux/
      apps, background = ["comix -f", "geeqie -f", "gqview -f", "eog"], true
    end

    apps.detect { |app| system("#{app} #{File.escape_name(real_path)} #{background ? '&' : ''}") }
  end

  def delete_original
    `rm -rf #{File.escape_name(real_path)}`
  end

  #Iterate recursively over all files/dirs
  #If current item is a zip/rar/cbr/cbz file, pull out first image and store zipe filename as manga name and zip filename as filename to load.
  #Else if current item is a dir, and it contains images but no directories, store the dir name as the manga name as well as the load filename.
  #Else skip/recurse into dir.

  IMAGE_EXTENSIONS = %w(.png .jpg .jpeg .gif)
  COMPRESSED_FILE_EXTENSIONS = %w(.zip .rar .cbz .cbr)
  ZIP_EXTENSIONS = %w(.zip .cbz)
  RAR_EXTENSIONS = %w(.rar .cbr)

  def self.import_and_update
    #Requires GNU find 3.8 or above
    cmd = <<-CMD
cd #{File.escape_name(DIR)} && find . -type d -o \\( -type f \\( #{COMPRESSED_FILE_EXTENSIONS.map { |ext| "-iname '*#{ext}'" }.join(' -o ')} \\) \\)
CMD

    path_list = IO.popen(cmd) { |s| s.read }
    path_list = path_list.split("\n").map { |e| e.gsub(/^\.\//, '') }.reject { |e| e[0, 1] == '.' }

    (Book.all.map(&:path) - path_list).each { |path| Book.find_by_path(path).destroy }

    path_list.reject { |e| Book.find_by_path(e) }.each do |e|
      if COMPRESSED_FILE_EXTENSIONS.include?(File.extname(e))
        import_compressed_file(e)
      else
        import_directory(e)
      end
    end
  end
  
  def self.import_compressed_file(relative_filename)
    real_filename = File.expand_path("#{DIR}/#{relative_filename}")

    #TODO: We move the file data around like a million times, we ought to be able to pass the input stream
    #directly from the zip file to the model or whatever
    temp_filename = "#{Dir.tmpdir}/#{ActiveSupport::SecureRandom.hex(20)}"
    filenames = []
    
    if ZIP_EXTENSIONS.include?(File.extname(real_filename))
      require 'zip/zip'
      zf = Zip::ZipFile.open(real_filename)
      filenames = zf.entries.map(&:name)
      
      first_image_filename = get_first_file(filenames)
      return if first_image_filename.nil?

      File.open(temp_filename, "w") { |f| f << zf.read(first_image_filename) }
    elsif RAR_EXTENSIONS.include?(File.extname(real_filename))
      #TODO: Very hacky, relies on compatible unrar binary
      filenames = IO.popen("cd #{File.escape_name(DIR)} && unrar vb #{File.escape_name(real_filename)}") { |s| s.read }
      filenames = filenames.split("\n")
      
      first_image_filename = get_first_file(filenames)
      return if first_image_filename.nil?

      IO.popen("cd #{File.escape_name(DIR)} && unrar p -inul #{File.escape_name(real_filename)} #{File.escape_name(first_image_filename)}") do |s|
        File.open(temp_filename, "w") { |f| f << s.read }
      end
    end
    
    return if filenames.nil?

    Book.create(:title => File.basename(real_filename).gsub(/_/, ' ').gsub(/#{COMPRESSED_FILE_EXTENSIONS.map { |e| Regexp.escape(e) }.join('|')}$/, ''),
     :path => relative_filename, :published_on => File.mtime(real_filename), :preview => File.open(temp_filename),
      :pages => filenames.count { |e| file_is_image(e) })

    File.unlink(temp_filename)
  end

  #dir should be findable from CWD or absolute; no trailing slash
  def self.import_directory(relative_dir)
    real_dir = File.expand_path("#{DIR}/#{relative_dir}")

    filename = get_first_file(Dir.entries(real_dir))
    return if filename.nil?

    title = File.basename(real_dir).gsub(/_/, ' ')

    pages = Dir.entries(real_dir).inject(0) { |sum, e| sum + (file_is_image("#{real_dir}/#{e}") ? 1 : 0) }

    Book.create(:title => title, :path => relative_dir, :published_on => File.mtime(real_dir),
     :preview => File.open("#{real_dir}/#{filename}"), :pages => pages)
  end


  def self.get_first_file(file_list)
    file_list.reject { |e| e[0, 1] == '.' || !file_is_image(e) }.sort.first
  end
  
  def self.file_is_image(filename)
    IMAGE_EXTENSIONS.include?(File.extname(filename).downcase)
  end
end