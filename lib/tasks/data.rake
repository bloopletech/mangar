namespace :data do
  task remove_duplicates: :environment do
    duplicates = ActiveRecord::Base.connection.select_values('SELECT path FROM items GROUP BY path HAVING COUNT(*) > 1')
    duplicates.each do |path|
      items = Item.where(path: path).order('page_count DESC, published_on DESC')

      delete_count = items.length - 1
      puts "For path #{items.first.path}, found #{items.length} #{items.length == 1 ? 'copy' : 'copies'}. Deleting " +
        "#{delete_count} oldest #{delete_count == 1 ? 'copy' : 'copies'}"

      items[1..-1].each { |item| item.destroy }
    end
  end
end