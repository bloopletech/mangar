class VideosController < ItemsController
  def show
    @video = Video.find(params[:id])
    @video.open

    ["gnome-mplayer", "mplayer"].detect { |app| system("#{app} #{File.escape_name(@video.real_path)} &") }
  end
end