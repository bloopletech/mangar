require 'item_preview_uploader'

class Book < Item
  PREVIEW_WIDTH = 197
  PREVIEW_HEIGHT = 310

  PREVIEW_SMALL_WIDTH = 98
  PREVIEW_SMALL_HEIGHT = 154

  #default_scope :order => 'published_on DESC'

  def page_paths
    self.class.image_file_list(real_path.children)
  end

  def page_urls
    page_paths.map { |path| "/system/books/#{path.relative_path_from(Mangar.books_dir)}" }
  end

  def rethumbnail
    begin
      start = Time.now
      puts "Rethumbnailing #{self.id}"
      book_dir = Mangar.books_dir + path
      puts "After step 1, #{Time.now - start}"
      images = self.class.image_file_list(book_dir.children)
      puts "After step 2, #{Time.now - start}"
      update_attribute(:preview, File.open(images.first, "r"))
      puts "After step 3, #{Time.now - start}"
    rescue => e
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
    end
  end

  def self.rethumbnail
    Book.all.each(&:rethumbnail)
  end

  def self.image_file_list(file_list)
    file_list.select { |e| File.image?(e) }.sort_by { |p| Naturally.normalize(File.basename(p)) }
  end
end
