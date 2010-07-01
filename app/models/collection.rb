class Collection
  attr_accessor :path, :id

  def ==(other)
    self.path == other.path
  end

  def initialize(data)
    self.path = File.expand_path(data['path'])
    self.id = data['id'] || rand(10000000).to_s #TODO: FIX
  end

  def create
    Collection.collections do |c|
      return if c.include?(self)
      c << self
    end
  end

  def destroy
    Collection.collections do |c|
      c.delete(self)
    end
  end

  def to_hash
    { 'id' => id, 'path' => path }
  end
  
  def self.find_by_path(path)
    collections.detect { |c| c.path == path }
  end

  def self.find_by_id(id)
    collections.detect { |c| c.id == id }
  end

  CONFIGURATION_PATH = "~/.mangar"

  def self.collections
    @@mutex ||= Mutex.new

    c = nil
    @@mutex.synchronize do
      c = get_collections

      if block_given?
        yield c
        File.open(config_path, 'w') { |f| YAML.dump(c.map(&:to_hash), f) }
      end
    end

    c unless block_given?
  end

  private
  def self.get_collections
    (File.exists?(config_path) ? YAML.load_file(config_path) : []).map { |c| Collection.new(c) }
  end

  def self.config_path
    File.expand_path(CONFIGURATION_PATH)
  end
end
        