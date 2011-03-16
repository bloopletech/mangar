class MoveBookImages < ActiveRecord::Migration
  def self.up
    FileUtils.mv("#{Mangar.mangar_dir}/public/system/books", "#{Mangar.mangar_dir}/public/system/book_previews") if File.exists?("#{Mangar.mangar_dir}/public/system/books")
    FileUtils.mv("#{Mangar.mangar_dir}/public/system/book_images", "#{Mangar.mangar_dir}/public/system/books") if File.exists?("#{Mangar.mangar_dir}/public/system/book_images")    
  end

  def self.down    
    #FileUtils.mv("#{Mangar.mangar_dir}/public/system/books", "#{Mangar.mangar_dir}/public/system/book_images") if File.exists?("#{Mangar.mangar_dir}/public/system/books")
    #FileUtils.mv("#{Mangar.mangar_dir}/public/system/book_previews", "#{Mangar.mangar_dir}/public/system/books") if File.exists?("#{Mangar.mangar_dir}/public/system/book_previews")
  end
end
