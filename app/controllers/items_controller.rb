require 'acts-as-taggable-on/version'
raise "Wrong ActsAsTaggableOn version!" unless ActsAsTaggableOn::VERSION == "2.3.3" #Needed to ensure our joins_values hack doesn't fail silently in new versions of AATO

class ItemsController < ApplicationController
  SORT_OPTIONS = [['Published', 'published_on'], ['A-Z', 'sort_key'], ['Last opened at', 'last_opened_at'], ['Date added', 'created_at'], ['Pages', 'pages'], ['Popularity', 'opens']]

  def index
    @items = _search_results.order(params[:sort_direction] == "RAND" ? "RANDOM()" : "#{params[:sort]} #{params[:sort_direction]}").paginate(:page => params[:page], :per_page => 100)
    
    @tags = Item.tag_counts_on(:tags).order("name ASC")
  end

  def bulk_export
    _search_results.each { |i| i.export }
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

  def dynamic_stylesheet
    self.formats = [:css]
  end

  private
  def _search_results
    params[:sort] ||= 'created_at'
    params[:sort_direction] ||= 'DESC'
    if !params[:search].blank?
      included_terms, excluded_terms = ActsAsTaggableOn::TagList.from(params[:search]).partition { |t| t.gsub!(/^-/, ''); $& != '-' }
      included_tags = included_terms.empty? ? [] : ActsAsTaggableOn::Tag.named_any(included_terms)
      excluded_tags = excluded_terms.empty? ? [] : ActsAsTaggableOn::Tag.named_any(excluded_terms)

      results = Item

      results = results.where("opens > 0") if included_terms.delete 's:read'
      results = results.where("opens = 0") if included_terms.delete 's:unread'
      #results = results.where("COUNT(taggings.id) > 0") if included_tags.delete 's:tagged'

      unless excluded_terms.empty?
        results = results.tagged_with(excluded_tags, :exclude => true) unless excluded_tags.empty?
        results = results.where(excluded_terms.map { |t| "NOT items.title LIKE #{qt t}" }.join(" AND "))
      end

      unless included_terms.empty?
        included_terms_sql = included_terms.map { |t| "items.title LIKE #{qt t}" }.join(" AND ")
        if included_tags.empty?
          results = results.where(included_terms_sql)
        else
          results = results.tagged_with(included_tags)
          results.joins_values.first.insert(0, "LEFT ")
          results = results.where("tag_id NOTNULL OR (#{included_terms_sql})")
        end
      end

      results
    else
      Item
    end
  end

  def qt(term)
    Item.connection.quote("%#{term}%")
  end
end
