class VideosController < ItemsController
  def show
    @video = Video.find(params[:id])

    ["play", "gnome-mplayer", "mplayer -alang jpn -sid 0"].detect { |app| system("#{app} #{File.escape_name(@video.real_path)} &") }

    #render :action => 'items/show'
  end
end