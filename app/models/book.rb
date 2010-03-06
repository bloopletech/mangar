require 'action_controller/test_process'

class Book < ActiveRecord::Base
#  acts_as_taggable

  has_attached_file :preview, :styles => { :medium => "200>" }




  IMAGE_EXTENSIONS = %w(.png .jpg .jpeg .gif)

  def self.import_and_update
    dir_list = IO.popen("find #{File.escape_name(DIR)} -type d") { |s| s.read }
    dir_list.split("\n").each { |e| import_directory(e) }
  end
=begin
  def self.process_directory(dir)
    entries = Dir.entries(dir).reject { |e| e[0, 1] == '.' }
    entries.select { |e| File.directory?("#{dir}/#{e}") }.each { |e| process_directory("#{dir}/#{e}") }
    import_directory(dir)
  end
=end
  #dir should be findable from CWD or absolute; no trailing slash
  def self.import_directory(dir)
    dir = File.expand_path(dir)

    filename = get_first_file(dir)
    return if filename.nil?

    title = File.basename(dir).gsub(/[_-]/, ' ')

    Book.create(:title => title, :directory => dir, :filename => filename, :published_on => File.mtime("#{dir}/#{filename}"),
     :preview => ActionController::TestUploadedFile.new("#{dir}/#{filename}"))
  end


  def self.get_first_file(dir)
    Dir.entries(dir).reject { |e| e[0, 1] == '.' || !file_is_image("#{dir}/#{e}") }.sort.first
  end
  
  def self.file_is_image(filename)
    IMAGE_EXTENSIONS.include?(File.extname(filename).downcase)
  end
end