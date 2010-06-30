class Collection
  def self.create(path)
    path = File.expand_path(path)

    Collection.collections do |c|
      return if c.include?(path)
      c << path
    end
  end

  def self.destroy(path)
    Collection.collections do |c|
      c.delete(path)
    end
  end

  CONFIGURATION_PATH = "~/.mangar"

  def self.collections
    @@mutex ||= Mutex.new

    c = nil
    @@mutex.synchronize do
      c = get_collections

      if block_given?
        yield c
        File.open(config_path, 'w') { |f| YAML.dump(c, f) }
      end
    end

    c unless block_given?
  end

  private
  def self.get_collections
    File.exists?(config_path) ? YAML.load_file(config_path) : []
  end

  def self.config_path
    File.expand_path(CONFIGURATION_PATH)
  end
end
        