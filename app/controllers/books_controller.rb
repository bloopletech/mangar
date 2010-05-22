class BooksController < ApplicationController
  def index
    @books = if !params[:search].blank?
      unless params[:search].blank?
        params[:page] = '1'

        included_tags, excluded_tags = ActsAsTaggableOn::TagList.from(params[:search]).partition { |t| t.gsub!(/^-/, ''); $& != '-' }

        results = Book
        results = results.tagged_with(excluded_tags, :exclude => true) unless excluded_tags.empty?
        results = results.tagged_with(included_tags) unless included_tags.empty?
        #results |= Book.where(included_tags.map { |t| "title LIKE #{ActiveRecord::Base.connection.quote "%#{t}%"}" }.join(" OR ")) unless included_tags.empty?
        results
      end

      results
    else
      Book.scoped
    end.order("#{params[:sort]} #{params[:sort_direction]}").paginate(:page => params[:page], :per_page => 50)
  end

  def show
    @book = Book.find(params[:id])
    @book.open
  end

  def update
    @book = Book.find(params[:id])
    if @book.update_attributes(params[:book])
      render :action => 'update_fields'
    else
      #boom
    end
  end

  def destroy
    @book = Book.find(params[:id])

    #if params[:delete]
      @book.delete_original
    #end

    @book.destroy
  end

  def import_and_update
    Thread.new do
      #Fix so we don't have to do this.
      BookPreviewUploader.root = CarrierWave.root = Rails.public_path
      Book.import_and_update
    end
  end
end