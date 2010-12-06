class VideosController < ItemsController
  def show
    @video = Video.find(params[:id])    

    ["gnome-mplayer", "mplayer"].detect { |app| system("#{app} #{File.escape_name(@video.real_path)} &") }

    #render :action => 'items/show'
  end
end