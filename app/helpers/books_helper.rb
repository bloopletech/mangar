module BooksHelper
  include ActsAsTaggableOn::TagsHelper

  def is_last_page?(collection)
    collection.total_pages == 0 || (collection.total_pages == (params[:page].blank? ? 1 : params[:page].to_i))
  end

  def books_with(new_params)
    books_path(params.except(:controller, :action, :page).merge(new_params))
  end
end