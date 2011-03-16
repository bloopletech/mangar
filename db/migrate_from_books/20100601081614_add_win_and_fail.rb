class AddWinAndFail < ActiveRecord::Migration
  def self.up
    add_column :books, :win, :boolean, :default => false
    add_column :books, :fail, :boolean, :default => false
  end

  def self.down
    remove_column :books, :win
    remove_column :books, :fail
  end
end
