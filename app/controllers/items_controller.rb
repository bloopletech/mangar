class ItemsController < ApplicationController
  def index
    params[:sort] ||= 'created_at'
    params[:sort_direction] ||= 'DESC'
    @items = if !params[:search].blank?
      included_tags, excluded_tags = ActsAsTaggableOn::TagList.from(params[:search]).partition { |t| t.gsub!(/^-/, ''); $& != '-' }

      results = Item
      
      results = results.where("opens > 0") if included_tags.delete 's:read'
      results = results.where("opens = 0") if included_tags.delete 's:unread'
      #results = results.where("COUNT(taggings.id) > 0") if included_tags.delete 's:tagged'
      


      results = results.tagged_with(excluded_tags, :exclude => true) unless excluded_tags.empty?
      results = results.tagged_with(included_tags) unless included_tags.empty?

      c = Item.connection
      #This next part makes me want to become an hero
      search_inc = included_tags.empty? ? nil : included_tags.map { |t| "items.title LIKE #{c.quote "%#{t}%"}" }.join(" AND ")
      search_ex = excluded_tags.empty? ? nil : excluded_tags.map { |t| "NOT items.title LIKE #{Item.connection.quote "%#{t}%"}" }.join(" AND ")
      
      results.where_values = ["(#{(results.where_values + [search_ex]).compact.map { |w| "(#{w})" }.join(" AND ")})" +
       (search_inc.nil? ? "" : " OR (#{search_inc})")]

      results
    else
      Item
    end.order("#{params[:sort]} #{params[:sort_direction]}").paginate(:page => params[:page], :per_page => 10)
    
    @tags = Item.tag_counts_on(:tags)
  end  

  def more_info
    @item = Item.find(params[:id])
    render :layout => 'secondary'
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
      Video.import_and_update
      Book.import_and_update
    #end
  end

  def info
    if Item.count == 0
      render :text => 'No items yet', :layout => 'secondary'
    end

    @oldest_book = Book.order('published_on ASC').first
    @newest_book = Book.order('published_on DESC').first
    @longest_book = Book.order('pages DESC').first
    @shortest_book = Book.order('pages ASC').first
    @most_popular_book = Book.order('opens DESC').first
    @least_popular_book = Book.order('opens ASC').first

    @oldest_video = Video.order('published_on ASC').first
    @newest_video = Video.order('published_on DESC').first
    @longest_video = Video.order('pages DESC').first
    @shortest_video = Video.order('pages ASC').first
    @most_popular_video = Video.order('opens DESC').first
    @least_popular_video = Video.order('opens ASC').first
    render :layout => 'secondary'
  end


  #TODO: Move someplace better
  def quit
    Process.kill("TERM", $$)
  end
end