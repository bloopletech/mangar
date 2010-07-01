require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

require 'fileutils'

ActsAsTaggableOn::TagList.delimiter = ' '

Time::DATE_FORMATS.merge!(:default => '%e %B %Y') #TODO fix so shows time as well
Date::DATE_FORMATS.merge!(:default => '%e %B %Y')

module Mangar
  class Application < Rails::Application
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





  mattr_accessor :dir, :mangar_dir

  def self.configure(path)
    Mangar.dir = path
    Mangar.mangar_dir = "#{Mangar.dir}/.mangar"
    
    new_app = !File.exists?(Mangar.mangar_dir)

    Application.instance.instance_eval do
      paths.public              "#{Mangar.mangar_dir}/public"
      paths.public.javascripts  "#{Mangar.mangar_dir}/public/javascripts"
      paths.public.stylesheets  "#{Mangar.mangar_dir}/public/stylesheets"

      config.middleware = Rails::Configuration::MiddlewareStackProxy.new
      @app = nil
    end
    
    ActiveRecord::Base.establish_connection({ :adapter => 'sqlite3', :database => "#{Mangar.mangar_dir}/db.sqlite3", :pool => 5, :timeout => 5000 })
    
    if new_app
      Dir.mkdir(Mangar.mangar_dir)
      Dir.mkdir("#{Mangar.mangar_dir}/public")
      ActiveRecord::Migrator.migrate("db/migrate/")
    end
    
    #NOTE: Removes files in Mangar.mangar_dir, if it's wrong could remove user files
    Dir.glob("#{Rails.root}/public/*").each { |f| FileUtils.rm_f("#{Mangar.mangar_dir}/#{File.basename(f)}") }
    FileUtils.ln_sf(Dir.glob("#{Rails.root}/public/*"), "#{Mangar.mangar_dir}/public")
  end
end

require Rails.root.join('lib/file_extensions')