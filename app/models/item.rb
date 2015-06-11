class Item < ActiveRecord::Base
  acts_as_taggable

  mount_uploader :preview, ItemPreviewUploader

  def real_path
    File.expand_path("#{Mangar.send("#{self.class.name.underscore.pluralize}_dir")}/#{path}")
  end

  def open
    increment!(:opens)
    update_attribute(:last_opened_at, DateTime.now)
  end

  def delete_original
    begin
      (Mangar.deleted_dir + path).dirname.mkpath
      File.rename(real_path, "#{Mangar.deleted_dir}/#{path}")
    rescue Exception => e
      ActionDispatch::ShowExceptions.new(Mangar::Application.instance).send(:log_error, e)
      return
    end
  end

  def export
    begin
      (Mangar.exported_dir + path).dirname.mkpath
      FileUtils.cp_r(real_path, "#{Mangar.exported_dir}/#{path}")
    rescue Exception => e
      ActionDispatch::ShowExceptions.new(Mangar::Application.instance).send(:log_error, e)
      return
    end
  end

  def self.sort_key(title)
    title.gsub(/[^A-Za-z0-9]+/, '').downcase
  end
end
