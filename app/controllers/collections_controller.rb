class CollectionsController < ApplicationController
  def index
    @collections = Collection.collections
  end

  def show
    puts "path: #{params[:path]}"
    return
    Mangar.setup(params[:path])
    redirect '/'
  end

  def create
    #If on gnome
    directory = IO.popen("zenity --file-selection --directory") { |s| s.read }
    
    unless directory.blank?
      Collection.create(directory)
    end

    redirect_to collections_path
  end

  def destroy
    Collection.destroy(params[:path])
  end
end