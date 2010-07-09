class CollectionsController < ApplicationController
  skip_before_filter :ensure_mangar_setup

  def index
    @collections = Collection.collections
  end

  def show
    Mangar.configure(Collection.find_by_id(params[:id].to_i))
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
    Collection.find_by_id(params[:id].to_i).destroy
    redirect_to collections_path
  end
end