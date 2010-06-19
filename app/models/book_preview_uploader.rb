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
      if File.video?(model.path)
        puts "it's a vid!"
        dir = Dir.tempdir
        system("mplayer -frames 1 -ss 30 -vo png outdir=#{File.escape_name(dir)} #{File.escape_name("#{DIR}/#{model.path}")}")
        puts File.size("#{dir}/00000001.png")
        #take shot, put into file
        #run img.store_pixels(0, 0, vid_img.columns, vid_img.rows, vid_img.get_pixels(0, 0, vid_img.columns, vid_img.rows))
      end
    
      if (img.columns > img.rows) && img.columns > Book::PREVIEW_WIDTH && img.rows > Book::PREVIEW_HEIGHT #if it's landscape-oriented
        img.crop!(Magick::EastGravity, img.rows / (Book::PREVIEW_HEIGHT / Book::PREVIEW_WIDTH.to_f), img.rows) #Resize it so the right-most part of the image is shown
      end
      img.change_geometry!("#{Book::PREVIEW_WIDTH}>") { |cols, rows, img| img.resize!(cols, rows) }
    end
  end
end