class CollectionsController < ApplicationController
  skip_before_filter :ensure_mangar_setup

  def index
    @collections = Collection.all
    render(:layout => 'secondary') if params[:from_items]
  end

  def show
    Mangar.configure(Collection.find(params[:id]))
    redirect_to '/'
  end

  def create
    #If on gnome
    directory = IO.popen("env -u WINDOWID zenity --file-selection --directory") { |s| s.read }
    
    unless directory.blank?
      params[:id] = Collection.create!(:path => directory.strip).id
      show
    else
      render :text => ''
    end
  end

  def edit
    @collection = Collection.find(params[:id])
    render :layout => 'secondary'
  end

  def update
    @collection = Collection.find(params[:id])
    
    if @collection.update_attributes(params[:collection])
      Mangar.collection = @collection

      flash[:success] = "Settings changed successfully."
      redirect_to collections_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @collection = Collection.find(params[:id])
    @collection.destroy
  end
end