class Pathname
  def descendant_directories
    out = []
    children.select { |p| p.directory? && !p.hidden? }.each do |p|
      if p.children.any? { |c| c.image? }
        out << p
      end
      out += p.descendant_directories
    end
    out
  end

  def image?
    file? && extname && %w(.jpg .jpeg .png .gif).include?(extname.downcase)
  end

  def hidden?
    basename.to_s[0..0] == "."
  end
end
