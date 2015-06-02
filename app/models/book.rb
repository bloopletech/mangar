require 'item_preview_uploader'

class Book < Item
  PREVIEW_WIDTH = 211
  PREVIEW_HEIGHT = 332

  PREVIEW_SMALL_WIDTH = 98
  PREVIEW_SMALL_HEIGHT = 154

  #default_scope :order => 'published_on DESC'

  def page_paths
    self.class.image_file_list(Dir.deep_entries(real_path)).map { |e| "/system/books/#{path}/#{e}" }
  end

  def rethumbnail
    begin
      start = Time.now
      puts "Rethumbnailing #{self.id}"
      book_dir = "#{Mangar.books_dir}/#{self.path}"
      puts "After step 1, #{Time.now - start}"
      images = self.class.image_file_list(Dir.deep_entries(book_dir))
      puts "After step 2, #{Time.now - start}"
      update_attribute(:preview, File.open("#{book_dir}/#{images.first}", "r"))
      puts "After step 3, #{Time.now - start}"
    rescue Exception => e
      ActionDispatch::ShowExceptions.new(Mangar::Application.instance).send(:log_error, e)
      return
    end
  end

  def self.rethumbnail
    Book.all.each(&:rethumbnail)
  end

  def self.image_file_list(file_list)
    file_list.select { |e| File.image?(e) }.sort_by { |p| Naturally.normalize(File.basename(p)) }
  end
end
