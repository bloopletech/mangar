class TitleFormatter
  def initialize(title)
    @title = title
  end

  def format
    exclusions.inject(@title) { |title, exclusion| title.gsub(exclusion, '') }.gsub(/\s+/, ' ').strip
  end

  def exclusions
    return [] if Preference['title_exclusions'].nil?
    Preference['title_exclusions'].split(',')
  end
end