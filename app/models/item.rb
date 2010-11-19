class Item < ActiveRecord::Base
  acts_as_taggable

  def real_path
    File.expand_path("#{Mangar.send("#{self.class.name.underscore.pluralize}_dir")}/#{path}")
  end

  def open
    increment!(:opens)
    update_attribute(:last_opened_at, DateTime.now)
  end

  def delete_original
    FileUtils.mkdir_p(File.dirname("#{Mangar.deleted_dir}/#{path}"))
    File.rename(real_path, "#{Mangar.deleted_dir}/#{path}")    
  end

  def self.sort_key(title)
    title.gsub(/[^A-Za-z0-9]+/, '').downcase
  end
end