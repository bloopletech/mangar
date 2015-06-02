class BookImporter
  COMPRESSED_FILE_EXTS = %w(.zip .rar .cbz .cbr)
  ZIP_EXTS = %w(.zip .cbz)
  RAR_EXTS = %w(.rar .cbr)

  VALID_EXTS = COMPRESSED_FILE_EXTS

  def initialize(relative_path)
    @relative_path = relative_path
  end

  def import
    real_path = File.expand_path("#{Mangar.import_dir}/#{@relative_path}")
    relative_dir = @relative_path.gsub('/', '__').gsub(/#{VALID_EXTS.map { |e| Regexp.escape(e) }.join('|')}$/, '')
    destination_dir = File.expand_path("#{Mangar.books_dir}/#{relative_dir}")

    last_modified = File.mtime(real_path)

    FileUtils.mkdir_p(destination_dir)

    begin
      if COMPRESSED_FILE_EXTS.include?(File.extname(@relative_path))
        data_from_compressed_file(real_path, destination_dir)
      else
        return if Dir.deep_entries(real_path).empty?
        data_from_directory(real_path, destination_dir)
      end
    rescue Exception => e
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
      return
    end

    images = Book.image_file_list(Dir.deep_entries(destination_dir))

    title = File.basename(relative_dir).gsub(/_/, ' ').gsub(/ +/, ' ').strip

    Book.create!(:title => title, :path => relative_dir, :published_on => last_modified,
     :preview => File.open("#{destination_dir}/#{images.first}"), :pages => images.length, :sort_key => Item.sort_key(title)) unless images.empty?

    FileUtils.rm_r(real_path) if File.exists?(real_path)
  end

  def data_from_compressed_file(real_path, destination_dir)
    if ZIP_EXTS.include?(File.extname(real_path))
      system("unzip #{File.escape_name(real_path)} -d #{File.escape_name(destination_dir)}")
    elsif RAR_EXTS.include?(File.extname(real_path))
      system("cd #{File.escape_name(destination_dir)} && unrar e #{File.escape_name(real_path)}")
    end
  end

  #dir should be findable from CWD or absolute; no trailing slash
  def data_from_directory(real_path, destination_dir)
    File.rename(real_path, destination_dir)
  end
end