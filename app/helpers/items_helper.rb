module ItemsHelper
  include ActsAsTaggableOn::TagsHelper

  def is_last_page?(collection)
    collection.total_pages == 0 || (collection.total_pages == (params[:page].blank? ? 1 : params[:page].to_i))
  end

  def items_with(new_params)
    items_path(params.except(:controller, :action, :page).merge(new_params))
  end

  def wbrize(str)
    str
    #str.split(' ').map { |sub_str| sub_str.split(/.{,30}/).join("<wbr>") }.join(' ')
  end

  def item_title(item, show)
    raw (show ? "<div class='title'>#{h wbrize(item.title)}</div>" : "")
  end
end