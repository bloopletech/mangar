class VideoPreviewUploader < ItemPreviewUploader
  def handle_image(img, p_width, p_height)
    puts "p_width: #{p_width}, p_height: #{p_height}"
    if (img.rows > img.columns) && img.columns > p_width && img.rows > p_height #if it's portrait-oriented
      img.crop!(Magick::CenterGravity, img.columns, img.columns / (p_width / p_height.to_f)) #Resize it so the right-most part of the image is shown
    end

    img.change_geometry!("#{p_width}>") { |cols, rows, img| img.resize!(cols, rows) }
  end
end