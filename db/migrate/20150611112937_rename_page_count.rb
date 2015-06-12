class RenamePageCount < ActiveRecord::Migration
  def up
    rename_column :items, :pages, :page_count
  end

  def down
    rename_column :items, :page_count, :pages
  end
end
