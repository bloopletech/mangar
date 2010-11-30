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
      puts "img.columns: #{img.columns}, img.rows: #{img.rows}"
      img = handle_image(img, model.class::PREVIEW_WIDTH, model.class::PREVIEW_HEIGHT)
      img.page = Magick::Rectangle.new(img.columns, img.rows, 0, 0)

      img
    end
  end  
end