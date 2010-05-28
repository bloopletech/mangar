class BooksController < ApplicationController
  def index
    params[:sort] ||= 'published_on'
    params[:sort_direction] ||= 'DESC' #TODO: these should be a default scope on book, but alas, arel is made of fail
    @books = if !params[:search].blank?
      included_tags, excluded_tags = ActsAsTaggableOn::TagList.from(params[:search]).partition { |t| t.gsub!(/^-/, ''); $& != '-' }

      results = Book
      results = results.tagged_with(excluded_tags, :exclude => true) unless excluded_tags.empty?
      results = results.tagged_with(included_tags) unless included_tags.empty?
      
      #This next part makes me want to becomean hero
      unless included_tags.empty?
        tagging_sql = results.order(' ').to_sql
        search_sql = Book.where(included_tags.map { |t| "books.title LIKE #{Book.connection.quote "%#{t}%"}" }.join(" OR ")).order(' ').to_sql
        results = Book.find_by_sql("#{tagging_sql} UNION #{search_sql} ORDER BY #{params[:sort]} #{params[:sort_direction]}")
      end

      results
    else
      Book.order("#{params[:sort]} #{params[:sort_direction]}")
    end.paginate(:page => params[:page], :per_page => 50)
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