class File
  def self.escape_name(f)
    f.gsub(/([ \[\]\(\)'"])/) { |r| "\\#{$1}" }
  end
end