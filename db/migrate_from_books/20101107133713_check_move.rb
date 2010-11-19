class CheckMove < ActiveRecord::Migration
  def self.up
    Book.all.each do |book|
      f_path = book.path.gsub(/#{Book::VALID_EXTS.map { |e| Regexp.escape(e) }.join('|')}$/, '') 
      if File.exists?("#{Mangar.book_images_dir}/#{f_path}")
        puts "Successfully moved #{book.title}"
      elsif File.exists?("#{Mangar.dir}/#{book.path}")
        puts "Haven't moved #{book.title} yet"
      else
        puts "Missing files for #{book.title}"
      end
    end
  end

  def self.down
  end
end
