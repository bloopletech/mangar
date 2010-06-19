class File
  def self.escape_name(filename)
    filename.gsub(/([ \[\]\(\)'"&!\\])/) { |r| "\\#{$1}" }
  end

  IMAGE_EXTENSIONS = %w(.png .jpg .jpeg .gif)
  VIDEO_EXTENSIONS = %w(.avi .mkv .mp4 .mpg .ogm)

  def self.image?(filename)
    IMAGE_EXTENSIONS.include?(File.extname(filename).downcase)
  end

  def self.video?(filename)
    VIDEO_EXTENSIONS.include?(File.extname(filename).downcase)
  end
end