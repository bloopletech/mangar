class ItemPreviewUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :file

  def store_dir
    "system/#{model.class.to_s.underscore}_previews/#{mounted_as}/#{model.id}"
  end

  #note that since model.id will be nil this will end up being ..//tmp, which the system handles nicely
  def cache_dir
    "#{store_dir}/tmp"
  end

  process :thumbnail

  def thumbnail
    p_width = model.class::PREVIEW_WIDTH
    p_height = model.class::PREVIEW_HEIGHT
    puts "p_width: #{p_width}, p_height: #{p_height}"

    manipulate! do |img|
      if (img.columns > img.rows) && img.columns > p_width && img.rows > p_height #if it's landscape-oriented
        img.crop!(Magick::EastGravity, img.rows / (p_height / p_width.to_f), img.rows) #Resize it so the right-most part of the image is shown
      end

      img.change_geometry!("#{p_width}>") { |cols, rows, img| img.resize!(cols, rows) }
      img.page = Magick::Rectangle.new(img.columns, img.rows, 0, 0)

      img
    end
  end
end