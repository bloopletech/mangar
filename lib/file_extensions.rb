class File
  def self.escape_name(filename)
    filename.gsub(/([ \[\]\(\)'"&!\\])/) { |r| "\\#{$1}" }
  end

  IMAGE_EXTENSIONS = %w(.png .jpg .jpeg .gif)

  def self.image?(filename)
    IMAGE_EXTENSIONS.include?(File.extname(filename).downcase)
  end
end