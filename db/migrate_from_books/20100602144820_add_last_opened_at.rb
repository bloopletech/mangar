class AddLastOpenedAt < ActiveRecord::Migration
  def self.up
    add_column :books, :last_opened_at, :timestamp
  end

  def self.down
    remove_column :books, :last_opened_at
  end
end
