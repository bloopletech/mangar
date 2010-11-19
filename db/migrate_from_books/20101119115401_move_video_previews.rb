class MoveVideoPreviews < ActiveRecord::Migration
  def self.up
    FileUtils.mv("#{Mangar.mangar_dir}/public/system/videos", "#{Mangar.mangar_dir}/public/system/video_previews") if File.exists?("#{Mangar.mangar_dir}/public/system/videos")
    FileUtils.mkdir("#{Mangar.mangar_dir}/public/system/videos") if !File.exists?("#{Mangar.mangar_dir}/public/system/videos")
  end

  def self.down
  end
end
