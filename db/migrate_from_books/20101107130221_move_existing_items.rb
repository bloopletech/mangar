class MoveExistingItems < ActiveRecord::Migration
  def self.up
    add_column :books, :upgraded, :boolean, :default => false

    Book.all.each do |book|
      next unless book.path.present?
      next if book.upgraded?
      puts "path: #{book.path}"
      relative_path = book.path
      real_path = File.expand_path("#{Mangar.dir}/#{relative_path}")

      unless File.exists?(real_path)
        puts "SKIPPING #{real_path}"
        next
      end

      relative_dir = relative_path.gsub(/#{Book::VALID_EXTS.map { |e| Regexp.escape(e) }.join('|')}$/, '')    
      destination_dir = File.expand_path("#{Mangar.book_images_dir}/#{relative_dir}")

      FileUtils.mkdir_p(destination_dir)

      if Book::COMPRESSED_FILE_EXTS.include?(File.extname(relative_path))
        Book.data_from_compressed_file(real_path, destination_dir)
      else
        Book.data_from_directory(real_path, destination_dir)
      end

      FileUtils.rm_r(real_path) if File.exists?(real_path)
      
      book.update_attribute(:upgraded, true)
    end
    
  end

  def self.down
  end
end
