class ItemsQuery
  SORTS = [
    ['Published', 'published_on'],
    ['A-Z', 'sort_key'],
    ['Last opened at', 'last_opened_at'],
    ['Date added', 'created_at'],
    ['Pages', 'page_count'],
    ['Popularity', 'opens']
  ]
  SORT_DIRECTIONS = [
    ['Descending', 'DESC'],
    ['Ascending', 'ASC'],
    ['Random', 'RAND']
  ]

  attr_reader :search, :sort, :sort_direction

  def initialize(query)
    query ||= {}
    @search = query['search']
    @sort = query['sort'].present? ? query['sort'] : 'published_on'
    @sort_direction = query['sort_direction'].present? ? query['sort_direction'] : 'DESC'
  end

  def results(relation = Item)
    if @search.present?
      included_terms, excluded_terms = ActsAsTaggableOn::TagList.from(@search).partition { |t| t.gsub!(/^-/, ''); $& != '-' }
      included_tags = included_terms.empty? ? [] : ActsAsTaggableOn::Tag.named_any(included_terms)
      excluded_tags = excluded_terms.empty? ? [] : ActsAsTaggableOn::Tag.named_any(excluded_terms)

      relation = special_terms(relation, included_terms, excluded_terms)

      unless excluded_terms.empty?
        relation = relation.tagged_with(excluded_tags, :exclude => true) unless excluded_tags.empty?
        relation = relation.where(excluded_terms.map { |t| "NOT items.title ILIKE #{qt t}" }.join(" AND "))
      end

      unless included_terms.empty?
        included_terms_sql = included_terms.map { |t| "items.title ILIKE #{qt t}" }.join(" AND ")
        if included_tags.empty?
          relation = relation.where(included_terms_sql)
        else
          relation = relation.tagged_with(included_tags)
          relation.joins_values.first.insert(0, "LEFT ")
          relation = relation.where("tag_id NOTNULL OR (#{included_terms_sql})")
        end
      end
    end

    relation.order(@sort_direction == "RAND" ? "RANDOM()" : "#{@sort} #{@sort_direction}")
  end

  def special_terms(relation, included_terms, excluded_terms)
    relation = relation.where("opens > 0") if included_terms.delete 's:read'
    relation = relation.where("opens = 0") if excluded_terms.delete 's:read'
    relation = relation.where("opens <= 3") if included_terms.delete 's:readish'
    relation = relation.where("opens > 3") if excluded_terms.delete 's:readish'
    relation = relation.where("opens = 0") if included_terms.delete 's:unread'
    relation = relation.where("opens > 0") if excluded_terms.delete 's:unread'
    relation = relation.where("page_count >= 150") if included_terms.delete 's:tank'
    relation = relation.where("page_count < 150") if excluded_terms.delete 's:tank'
    relation = relation.where("page_count >= 80") if included_terms.delete 's:long'
    relation = relation.where("page_count < 80") if excluded_terms.delete 's:long'
    relation = relation.where("page_count <= 30") if included_terms.delete 's:short'
    relation = relation.where("page_count > 30") if excluded_terms.delete 's:short'
    #relation = relation.where("COUNT(taggings.id) > 0") if included_tags.delete 's:tagged'
    relation
  end

  def qt(term)
    Item.connection.quote("%#{term}%")
  end
end