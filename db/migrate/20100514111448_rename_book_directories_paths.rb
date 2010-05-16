class RenameBookDirectoriesPaths < ActiveRecord::Migration
  def self.up
    rename_column :books, :directory, :path
  end

  def self.down
    rename_column :books, :path, :directory
  end
end
