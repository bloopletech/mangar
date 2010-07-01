class Collection
  attr_accessor :path, :id

  def ==(other)
    self.path == other.path
  end

  def initialize(data)
    self.path = File.expand_path(data['path'])
    self.id = (data['id'] || rand(10000000)).to_i #TODO: FIX
  end

  def create
    Collection.with_configuration do |c|
      return if c[:collections].include?(self)
      c[:collections] << self
    end
  end

  def destroy
    Collection.with_configuration { |c| c[:collections].delete(self) }
  end

  def to_hash
    { 'id' => id, 'path' => path }
  end
  
  def self.find_by_path(path)
    with_configuration[:collections].detect { |c| c.path == path }
  end

  def self.find_by_id(id)
    with_configuration[:collections].detect { |c| c.id == id }
  end

  def self.collections
    with_configuration[:collections]
  end

  def self.most_recently_used
    mru_id = nil
    with_configuration { |c| mru_id = c[:most_recently_used_id] }

    return nil unless mru_id
    return find_by_id(mru_id.to_i)
  end

  def self.most_recently_used=(collection)
    with_configuration do |c|
      c[:most_recently_used_id] = collection.id
    end
  end

  CONFIGURATION_PATH = "~/.mangar"

  private
  def self.with_configuration
    configuration = nil

    @@mutex ||= Mutex.new
    @@mutex.synchronize do
      configuration = (File.exists?(config_path) ? YAML.load_file(config_path) : {})

      configuration[:collections] ||= []
      configuration[:collections].map! { |c| Collection.new(c) } if configuration.key? :collections
      
      if block_given?
        yield configuration

        configuration[:collections].map!(&:to_hash) if configuration.key? :collections

        File.open(config_path, 'w') { |f| YAML.dump(configuration, f) }
      end
    end

    configuration
  end

  def self.config_path
    File.expand_path(CONFIGURATION_PATH)
  end
end
        