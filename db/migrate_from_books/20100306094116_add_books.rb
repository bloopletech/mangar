class AddBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string :title, :limit => 500

      t.text :directory #Directory of book
      t.text :filename #File name of first file

      t.text :preview
#      t.text :preview_content_type
#      t.text :preview_file_size
#      t.text :preview_updated_at

      t.integer :opens, :default => 0
      t.integer :pages, :default => 0

      t.timestamp :published_on

      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end
