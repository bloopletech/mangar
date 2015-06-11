class BookImporter
  COMPRESSED_FILE_EXTS = %w(.zip .rar .cbz .cbr)
  ZIP_EXTS = %w(.zip .cbz)
  RAR_EXTS = %w(.rar .cbr)

  VALID_EXTS = COMPRESSED_FILE_EXTS

  def initialize(path)
    @path = Pathname.new(path)
  end

  def relative_path
    @path.relative_path_from(Mangar.import_dir)
  end

  def destination_dir
    Mangar.books_dir + relative_path
  end

  def import
    if @path.children.any? { |c| c.directory? }
      raise "has child directories; will retry later"
    end

    last_modified = @path.mtime

    import_path

    return if images.empty?

    Book.create!(
      title: title,
      path: relative_path.to_s,
      published_on: last_modified,
      preview: File.open(images.first),
      pages: images.length,
      sort_key: Item.sort_key(title)
    )
  end

  def images
    @images ||= Book.image_file_list(destination_dir.children.map(&:to_s))
  end

  def title
    relative_path.to_s.gsub("/", " / ").gsub(/_/, ' ').gsub(/ +/, ' ').strip
  end

  def import_path
    destination_dir.dirname.mkpath

    if COMPRESSED_FILE_EXTS.include?(@path.extname)
      #data_from_compressed_file
    else
      data_from_directory
    end
  end

  def data_from_compressed_file
    if ZIP_EXTS.include?(@path.extname)
      system("unzip #{File.escape_name(@path)} -d #{File.escape_name(destination_dir)}")
    elsif RAR_EXTS.include?(@path.extname)
      system("cd #{File.escape_name(destination_dir)} && unrar e #{File.escape_name(@path)}")
    end
    @path.unlink if @path.exist?
  end

  def data_from_directory
    move_directory
    FileUtils.chmod_R(0755, destination_dir.to_s)
  end

  def move_directory
    @path.rename(destination_dir)
  rescue Errno::ENOTEMPTY
    @path.children.select { |c| c.file? }.each do |c|
      c.rename(destination_dir + c.basename)
    end
    @path.unlink if @path.children.empty?
  end
end
