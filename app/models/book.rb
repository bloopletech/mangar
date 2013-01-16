require 'item_preview_uploader'

class Book < Item
  PREVIEW_WIDTH = 212
  PREVIEW_HEIGHT = 333

  PREVIEW_SMALL_WIDTH = 98
  PREVIEW_SMALL_HEIGHT = 154

  #default_scope :order => 'published_on DESC'

  def page_paths
    self.class.image_file_list(Dir.deep_entries(real_path)).map { |e| "/system/books/#{path}/#{e}" }
  end

  COMPRESSED_FILE_EXTS = %w(.zip .rar .cbz .cbr)
  ZIP_EXTS = %w(.zip .cbz)
  RAR_EXTS = %w(.rar .cbr)
  
  VALID_EXTS = COMPRESSED_FILE_EXTS

  #Iterate recursively over all files/dirs
  #If current item is a zip/rar/cbr/cbz file, pull out first image and store zip filename as manga name and zip filename as filename to load.
  #Else if current item is a dir, and it contains images but no directories, store the dir name as the manga name as well as the load filename.
  #Else skip/recurse into dir.
  #Do not call more than once at a time
  def self.import_and_update
    #Requires GNU find 3.8 or above
    cmd = <<-CMD
cd #{File.escape_name(Mangar.import_dir)} && find . -depth -type d -o \\( -type f \\( #{VALID_EXTS.map { |ext| "-iname '*#{ext}'" }.join(' -o ')} \\) \\)
CMD

    $stdout.puts #This makes it actually import; fuck knows why

    path_list = IO.popen(cmd) { |s| s.read }
    path_list = path_list.split("\n").map { |e| e.gsub(/^\.\//, '') }.reject { |e| e[0, 1] == '.' }

    path_list.each { |path| self.import(path) }
    
    system("cd #{File.escape_name(Mangar.import_dir)} && find . -depth -type d -empty -exec rmdir {} \\;")
  end

  def self.import(relative_path)
    real_path = File.expand_path("#{Mangar.import_dir}/#{relative_path}")
    relative_dir = relative_path.gsub('/', '__').gsub(/#{VALID_EXTS.map { |e| Regexp.escape(e) }.join('|')}$/, '')
    destination_dir = File.expand_path("#{Mangar.books_dir}/#{relative_dir}")
    
    last_modified = File.mtime(real_path)
    
    FileUtils.mkdir_p(destination_dir)

    begin
      if COMPRESSED_FILE_EXTS.include?(File.extname(relative_path))
        data_from_compressed_file(real_path, destination_dir)
      else
        return if Dir.deep_entries(real_path).empty?
        data_from_directory(real_path, destination_dir)
      end
    rescue Exception => e
      ActionDispatch::ShowExceptions.new(Mangar::Application.instance).send(:log_error, e)
      return
    end

    images = image_file_list(Dir.deep_entries(destination_dir))

    title = File.basename(relative_dir).gsub(/_/, ' ').gsub(/ +/, ' ').strip
    
    Book.create!(:title => title, :path => relative_dir, :published_on => last_modified,
     :preview => File.open("#{destination_dir}/#{images.first}"), :pages => images.length, :sort_key => Item.sort_key(title)) unless images.empty?

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

  def rethumbnail
    begin
      start = Time.now
      puts "Rethumbnailing #{self.id}"
      book_dir = File.expand_path("#{Mangar.books_dir}/#{path}")
      puts "After step 1, #{Time.now - start}"
      images = self.class.image_file_list(Dir.deep_entries(book_dir))
      puts "After step 2, #{Time.now - start}"
      update_attribute(:preview, File.open("#{book_dir}/#{images.first}", "r"))
      puts "After step 3, #{Time.now - start}"
    rescue Exception => e
      ActionDispatch::ShowExceptions.new(Mangar::Application.instance).send(:log_error, e)
      return
    end
  end

  def self.rethumbnail
    Book.all.each(&:rethumbnail)
  end

  def self.image_file_list(file_list)
    file_list.select { |e| File.image?(e) }.sort_by { |s| s.split(/(\d+)/).map { |p| Integer(p, 10) rescue p }.reject { |p| p == "" } }
  end
end
