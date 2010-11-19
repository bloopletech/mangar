class PostprocessUpgrade < ActiveRecord::Migration
  def self.up
    Book.all.each do |book|
      relative_dir = book.path.gsub(/#{Book::VALID_EXTS.map { |e| Regexp.escape(e) }.join('|')}$/, '')
      book.update_attribute(:path, relative_dir)
    end
  end

  def self.down
  end
end
