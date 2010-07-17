class AddSortKeys < ActiveRecord::Migration
  def self.up
    add_column :books, :sort_key, :string

    Book.find_each do |book|
      book.update_attribute(:sort_key, Book.sort_key(book.title))
    end
  end

  def self.down
    remove_column :books, :sort_key
  end
end
