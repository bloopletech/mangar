module BooksHelper
  include ActsAsTaggableOn::TagsHelper

  def is_last_page?(collection)
  puts "collection: #{collection.total_pages}, params[:page]: #{params[:page]}"
    collection.total_pages <= params[:page].to_i
  end
end