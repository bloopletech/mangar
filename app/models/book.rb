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
    File.expand_path("#{Mangar.book_images_dir}/#{path}")
  end

  def page_paths
    self.class.image_file_list(Dir.entries(real_path)).map { |e| "/system/book_images/#{path}/#{e}" }
  end

  def open
    increment!(:opens)
    update_attribute(:last_opened_at, DateTime.now)
  end

  def delete_original
    `rm -rf #{File.escape_name(real_path)}`
  end

  COMPRESSED_FILE_EXTS = %w(.zip .rar .cbz .cbr)
  ZIP_EXTS = %w(.zip .cbz)
  RAR_EXTS = %w(.rar .cbr)
  
  VALID_EXTS = COMPRESSED_FILE_EXTS# + File::VIDEO_EXTS

  #Iterate recursively over all files/dirs
  #If current item is a zip/rar/cbr/cbz file, pull out first image and store zip filename as manga name and zip filename as filename to load.
  #Else if current item is a dir, and it contains images but no directories, store the dir name as the manga name as well as the load filename.
  #Else skip/recurse into dir.
  #Do not call more than once at a time
  def self.import_and_update
    #Requires GNU find 3.8 or above
    cmd = <<-CMD
cd #{File.escape_name(Mangar.dir)} && find . -depth -type d -o \\( -type f \\( #{VALID_EXTS.map { |ext| "-iname '*#{ext}'" }.join(' -o ')} \\) \\)
CMD

    $stdout.puts #This makes it actually import; fuck knows why

    path_list = IO.popen(cmd) { |s| s.read }
    path_list = path_list.split("\n").map { |e| e.gsub(/^\.\//, '') }.reject { |e| e[0, 1] == '.' }

    path_list.each { |path| self.import(path) }
  end

  def self.import(relative_path) 
    real_path = File.expand_path("#{Mangar.dir}/#{relative_path}")
    relative_dir = relative_path.gsub(/#{VALID_EXTS.map { |e| Regexp.escape(e) }.join('|')}$/, '')    
    destination_dir = File.expand_path("#{Mangar.book_images_dir}/#{relative_dir}")
    
    last_modified = File.mtime(real_path)
    
    FileUtils.mkdir_p(destination_dir)

    begin      
      if COMPRESSED_FILE_EXTS.include?(File.extname(relative_path))
        data_from_compressed_file(real_path, destination_dir)
      else
        data_from_directory(real_path, destination_dir)
      end      
    rescue Exception => e
      ActionDispatch::ShowExceptions.new(Mangar::Application.instance).send(:log_error, e)
      return
    end

    images = image_file_list(Dir.entries(destination_dir))

    title = File.basename(relative_dir).gsub(/_/, ' ')
    Book.create!(:title => title, :path => relative_dir, :published_on => last_modified,
     :preview => File.open("#{destination_dir}/#{images.first}"), :pages => images.length, :sort_key => Book.sort_key(title)) unless images.empty?

    FileUtils.rm_r(real_path) if File.exists?(real_path) 
  end

  def self.data_from_compressed_file(real_path, destination_dir)    
    if ZIP_EXTS.include?(File.extname(real_path))
      system("unzip #{File.escape_name(real_path)} -d #{File.escape_name(destination_dir)}")      
    elsif RAR_EXTS.include?(File.extname(real_path))
      system("cd #{File.escape_name(destination_dir)} && unrar e #{File.escape_name(real_path)}")      
    end    
  end

  #dir should be findable from CWD or absolute; no trailing slash
  def self.data_from_directory(real_path, destination_dir)          
    File.rename(real_path, destination_dir)    
  end

  #Needs rewrite
  def self.reprocess
    Book.all.each do |book|
      real_path = File.expand_path("#{Mangar.dir}/#{book.path}")
    
      first_image_io, page_count = if COMPRESSED_FILE_EXTS.include?(File.extname(real_path))
        data_from_compressed_file(real_path)
      else
        data_from_directory(real_path)
      end
    
      next if first_image_io.nil?

      book.update_attribute(:preview, first_image_io)
    end
  end

  def self.image_file_list(file_list)
    file_list.reject { |e| e[0, 1] == '.' || !File.image?(e) }.sort
  end

  def self.sort_key(title)
    title.gsub(/[^A-Za-z0-9]+/, '').downcase
  end
end