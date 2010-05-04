class BooksController < ApplicationController
  def index
    @books = if !params[:search].blank? || params[:sort] || params[:sort_direction]
      opts = { :order => "#{params[:sort]} #{params[:sort_direction]}" }

      unless params[:search].blank?
        included_tags, excluded_tags = TagList.from(params[:search]).partition { |t| t.gsub!(/^-/, ''); $& != '-' }

        opts.merge!(:conditions => [], :joins => [], :group => [], :readonly => [])
        
        ([Book.find_options_for_find_tagged_with(excluded_tags, :exclude => true)] + included_tags.map { |t| Book.find_options_for_find_tagged_with(t) }).each { |c| c.each_pair { |k, v| opts[k] << v } }

        opts[:conditions] = opts[:conditions].reject { |c| c.blank? }.map { |c| "(#{c})" }.join(" AND ")
        opts[:joins] = opts[:joins].reject { |j| j.blank? }.join(" ")
        opts[:group] = opts[:group].reject { |g| g.blank? }.join(", ")

        [:joins, :group].each { |k| opts.delete(k) if opts[k] == '' } #note that impl. of tag lib is it always returns conditions

        opts[:conditions] = "(#{opts[:conditions]}) OR (#{included_tags.map { |t| "title LIKE '#{t}%'" }.join(" OR ")})" unless included_tags.empty?
        opts[:readonly] = false
      end

      Book.all(opts)
    else
      Book.all
    end
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

  def import_and_update
    Thread.new do
      #Fix so we don't have to do this.
      BookPreviewUploader.root = CarrierWave.root = Rails.public_path
      Book.import_and_update
    end
    render :text => ""
  end
end