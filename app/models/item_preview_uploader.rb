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
    manipulate! do |img|
      p_width = model.class::PREVIEW_WIDTH
      p_height = model.class::PREVIEW_HEIGHT
      img = send("handle_#{model.class.name.downcase}_image", img, p_width, p_height)
      img.page = Magick::Rectangle.new(img.columns, img.rows, 0, 0)
      img = img.extent(p_width, p_height, 0, 0)
      img.excerpt!(0, 0, p_width, p_height)

      img
    end
  end

  def handle_book_image(img, p_width, p_height)
    if (img.columns > img.rows) && img.columns > p_width && img.rows > p_height #if it's landscape-oriented
      img.crop!(Magick::EastGravity, img.rows / (p_height / p_width.to_f), img.rows) #Resize it so the right-most part of the image is shown
    end

    img.change_geometry!("#{p_width}>") { |cols, rows, _img| _img.resize!(cols, rows) }

    img
  end

  def handle_video_image(img, p_width, p_height)
    puts "p_width: #{p_width}, p_height: #{p_height}"
    if (img.rows > img.columns) && img.columns > p_width && img.rows > p_height #if it's portrait-oriented
      img.crop!(Magick::CenterGravity, img.columns, img.coluchange_geometrymns / (p_width / p_height.to_f)) #Resize it so the right-most part of the image is shown
    end

    img.change_geometry!("#{p_width}>") { |cols, rows, img| img.resize!(cols, rows) }
    #img
  end
end