class Dir
  #Note: will not return . and ..
  def self.deep_entries(dir)
    dir_regex = /^#{Regexp.escape(dir)}\//    
    Dir.glob("#{dir}/**/*").map { |d| d.sub(dir_regex, '') }
  end
end