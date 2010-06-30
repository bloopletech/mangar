class Config
  def config
    YAML.load_file(RAILS_ROOT + "/config/config.yml")
  end
end