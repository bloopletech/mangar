class BooksController < ApplicationController
  def index
    @books = if !params[:search].blank?
      included_tags, excluded_tags = ActsAsTaggableOn::TagList.from(params[:search]).partition { |t| t.gsub!(/^-/, ''); $& != '-' }

      results = Book
      
      results = results.where("opens > 0") if included_tags.delete 's:read'
      results = results.where("opens = 0") if included_tags.delete 's:unread'
      #results = results.where("COUNT(taggings.id) > 0") if included_tags.delete 's:tagged'
      


      results = results.tagged_with(excluded_tags, :exclude => true) unless excluded_tags.empty?
      results = results.tagged_with(included_tags) unless included_tags.empty?

      c = Book.connection
      #This next part makes me want to become an hero
      search_inc = included_tags.empty? ? nil : included_tags.map { |t| "books.title LIKE #{c.quote "%#{t}%"}" }.join(" OR ")
      search_ex = excluded_tags.empty? ? nil : excluded_tags.map { |t| "NOT books.title LIKE #{Book.connection.quote "%#{t}%"}" }.join(" AND ")
      
      results.where_values = ["(#{(results.where_values + [search_ex]).compact.map { |w| "(#{w})" }.join(" AND ")})" +
       (search_inc.nil? ? "" : " OR (#{search_inc})")]

      results
    else
      Book
    end.order("#{params[:sort] || 'published_on'} #{params[:sort_direction] || 'DESC'}").paginate(:page => params[:page], :per_page => 50)
    
    @tags = Book.tag_counts_on(:tags)
  end

  def show
    @book = Book.find(params[:id])
    @book.open
  end

  def more_info
    @book = Book.find(params[:id])
    render :layout => 'secondary'
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
    #Thread.new do #Temporarily remopve threading as it seems to be causing import problems
      #Fix so we don't have to do this.
      BookPreviewUploader.root = CarrierWave.root = Rails.public_path
      Book.import_and_update
    #end
  end
end