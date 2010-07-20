class CollectionsController < ApplicationController
  skip_before_filter :ensure_mangar_setup

  def index
    @collections = Collection.all
  end

  def show
    Mangar.configure(Collection.find(params[:id]))
    redirect_to '/'
  end

  def create
    #If on gnome
    directory = IO.popen("env -u WINDOWID zenity --file-selection --directory") { |s| s.read }
    
    unless directory.blank?
      Collection.create!(:path => directory.strip)
    end

    redirect_to collections_path
  end

  def edit
    @collection = Collection.find(params[:id])
    @config = @collection.config || {}
  end

  def destroy
    Collection.find(params[:id]).destroy
    redirect_to collections_path
  end
end