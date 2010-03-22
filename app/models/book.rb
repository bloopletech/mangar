require 'book_preview_uploader'

class Book < ActiveRecord::Base
  acts_as_taggable

#  has_attached_file :preview, :url => "file://#{MANGAR_DIR}/system/:attachment/:id/:style/:filename", :path => "#{MANGAR_DIR}/system/:attachment/:id/:style/:filename", :styles => { :medium => "200>" }, :default_style => :medium
#  has_attached_file :preview, :path => "#{MANGAR_DIR}/system/:attachment/:id/:style/:filename", :styles => { :medium => "200>" }, :default_style => :medium

  mount_uploader :preview, BookPreviewUploader


  default_scope :order => 'published_on DESC'



  def real_directory
    File.expand_path("#{DIR}/#{directory}")
  end


  IMAGE_EXTENSIONS = %w(.png .jpg .jpeg .gif)

  def self.import_and_update
    dir_list = IO.popen("cd #{File.escape_name(DIR)} && find . -type d") { |s| s.read }
    dir_list.split("\n").map { |e| e.gsub(/^\.\//, '') }.reject { |e| e[0, 1] == '.' }.each { |e| import_directory(e) }
  end

  #dir should be findable from CWD or absolute; no trailing slash
  def self.import_directory(relative_dir)
    return nil if Book.find_by_directory(relative_dir)

    real_dir = File.expand_path("#{DIR}/#{relative_dir}")

    filename = get_first_file(real_dir)
    return if filename.nil?

    title = File.basename(real_dir).gsub(/[_-]/, ' ')
    
    pages = Dir.entries(real_dir).inject(0) { |sum, e| sum + (file_is_image("#{real_dir}/#{e}") ? 1 : 0) }

    Book.create(:title => title, :directory => relative_dir, :filename => filename, :published_on => File.mtime(real_dir),
     :preview => File.open("#{real_dir}/#{filename}"), :pages => pages)
  end


  def self.get_first_file(dir)
    Dir.entries(dir).reject { |e| e[0, 1] == '.' || !file_is_image("#{dir}/#{e}") }.sort.first
  end
  
  def self.file_is_image(filename)
    IMAGE_EXTENSIONS.include?(File.extname(filename).downcase)
  end
end