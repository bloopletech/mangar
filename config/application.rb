require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

require 'fileutils'

ActsAsTaggableOn::TagList.delimiter = ' '

Time::DATE_FORMATS.merge!(:default => '%e %B %Y') #TODO fix so shows time as well
Date::DATE_FORMATS.merge!(:default => '%e %B %Y')

require File.dirname(__FILE__) + '/../lib/system_static_middleware'

module Mangar
  class Application < Rails::Application
    config.middleware.insert_before ::ActionDispatch::Static, ::Mangar::SystemStaticMiddleware
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{config.root}/extras )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end


  DEFAULT_DB_CONFIG = { :adapter => 'sqlite3', :pool => 5, :timeout => 5000 }
  COLLECTION_DB_CONFIG = DEFAULT_DB_CONFIG.merge(:database => File.expand_path("~/.mangar.sqlite3"))

  mattr_accessor :collection, :dir, :mangar_dir, :books_dir, :videos_dir, :deleted_dir, :exported_dir, :import_dir

  def self.configure(collection)
    Mangar.collection = collection
    Mangar.dir = collection.path
    Mangar.mangar_dir = collection.mangar_path
    Mangar.books_dir = File.expand_path("#{Mangar.mangar_dir}/public/system/books")
    Mangar.videos_dir = File.expand_path("#{Mangar.mangar_dir}/public/system/videos")
    Mangar.import_dir = File.expand_path("#{Mangar.dir}/import")
    Mangar.exported_dir = File.expand_path("#{Mangar.dir}/exported")
    Mangar.deleted_dir = File.expand_path("#{Mangar.dir}/deleted")

    Dir.mkdir(Mangar.mangar_dir) if !File.exists?(Mangar.mangar_dir)
    [Mangar.books_dir, Mangar.videos_dir, Mangar.import_dir, Mangar.deleted_dir, Mangar.exported_dir].each { |d| FileUtils.mkdir_p(d) unless File.exists?(d) }

    db_config = DEFAULT_DB_CONFIG.merge(:database => "#{Mangar.mangar_dir}/db.sqlite3")

    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Migrator.migrate("db/migrate/")
    ActiveRecord::Base.establish_connection(db_config)

    collection.opened!
  end
end

module CarrierWave
  class << self
    def root
      "#{Mangar.mangar_dir}/public"
    end
  end
end

require Rails.root.join('lib/file_extensions')
require Rails.root.join('lib/dir_extensions')
