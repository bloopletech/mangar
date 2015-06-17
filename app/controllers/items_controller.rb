require 'acts-as-taggable-on/version'
raise "Wrong ActsAsTaggableOn version!" unless ActsAsTaggableOn::VERSION == "2.3.3" #Needed to ensure our joins_values hack doesn't fail silently in new versions of AATO

class ItemsController < ApplicationController
  def index
    @query = ItemsQuery.new(params[:query])
    @items = @query.results.paginate(page: params[:page], per_page: 100)

    @tags = Item.tag_counts_on(:tags).order("name ASC")
    render partial: 'items' if request.xhr?
  end

  def bulk_export
    ItemsQuery.new(params[:query]).results.each { |i| i.export }
  end

  def more_info
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      render :action => 'update_fields'
    else
      #boom
    end
  end

  def destroy
    @item = Item.find(params[:id])

    #if params[:delete]
    @item.delete_original
    #end

    @item.destroy
  end

  def import_and_update
    #Thread.new do #Temporarily remopve threading as it seems to be causing import problems
      #Video.import_and_update
      BooksImporter.new.import_and_update
    #end
  end

  def info
    if Item.count == 0
      render text: 'No items yet'
    end

    @oldest_book = Book.order('published_on ASC').first
    @newest_book = Book.order('published_on DESC').first
    @longest_book = Book.order('page_count DESC').first
    @shortest_book = Book.order('page_count ASC').first
    @most_popular_book = Book.order('opens DESC').first
    @least_popular_book = Book.order('opens ASC').first

    @oldest_video = Video.order('published_on ASC').first
    @newest_video = Video.order('published_on DESC').first
    @longest_video = Video.order('page_count DESC').first
    @shortest_video = Video.order('page_count ASC').first
    @most_popular_video = Video.order('opens DESC').first
    @least_popular_video = Video.order('opens ASC').first
  end


  #TODO: Move someplace better
  def quit
    Process.kill("TERM", $$)
  end

  def dynamic_stylesheet
    self.formats = [:css]
  end
end
