class CollectionsController < ApplicationController
  def index
    @collections = Collection.collections
  end

  def show
    Mangar.setup(Collection.find_by_id(params[:id]).path)
    redirect_to '/'
  end

  def create
    #If on gnome
    directory = IO.popen("zenity --file-selection --directory") { |s| s.read }
    
    unless directory.blank?
      Collection.new('path' => directory.strip).create
    end

    redirect_to collections_path
  end

  def destroy
    Collection.find_by_id(params[:id]).destroy
  end
end