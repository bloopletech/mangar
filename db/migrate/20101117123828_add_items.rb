class AddItems < ActiveRecord::Migration
  def self.up
    rename_table :books, :items
    add_column :items, :type, :string
    Item.all.each { |item| item.update_attribute(:type, 'Book') }
    ActsAsTaggableOn::Tagging.all.each { |t| t.update_attribute(:taggable_type, 'Item') }
    #Item.all.each { |item| item.update_attribute(:type, item.path.'book') }
  end

  def self.down
    remove_column :items, :type
    rename_table :items, :books
  end
end
