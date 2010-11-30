class BookPreviewUploader < ItemPreviewUploader
  def handle_image(img, p_width, p_height)
    puts "p_width: #{p_width}, p_height: #{p_height}"
    if (img.columns > img.rows) && img.columns > p_width && img.rows > p_height #if it's landscape-oriented
      img.crop!(Magick::EastGravity, img.rows / (p_height / p_width.to_f), img.rows) #Resize it so the right-most part of the image is shown
    end

    img.change_geometry!("#{p_width}>") { |cols, rows, img| img.resize!(cols, rows) }
  end
end