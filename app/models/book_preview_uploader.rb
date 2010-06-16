class BookPreviewUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :file

  def store_dir
    "system/#{model.class.to_s.underscore.pluralize}/#{mounted_as}/#{model.id}"
  end

  #note that since model.id will be nil this will end up being ..//tmp, which the system handles nicely
  def cache_dir
    "#{store_dir}/tmp"
  end

  process :thumbnail

  def thumbnail
    manipulate! do |img|
      #puts "checking image: #{img.columns}, #{img.rows}"
      if (img.columns > img.rows) && img.columns > 200 && img.rows > 314 #if it's landscape-oriented
        #puts "croppping"
        img.crop!(Magick::EastGravity, 0.636942675159236 * img.columns, img.rows) 
      end
      img.change_geometry!("200>") { |cols, rows, img| img.resize!(cols, rows) }
    end
  end
end