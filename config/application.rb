require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

require 'fileutils'

#More special config

ActsAsTaggableOn::TagList.delimiter = ' '

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


  def self.setup(path)
    Mangar.dir = path #Temporary?
    Mangar.mangar_dir = "#{Mangar.dir}/.mangar" #Temporary?
    
    new_app = !File.exists?(Mangar.mangar_dir)


    #...
     
    Application.class_eval do
      paths.public              "#{Mangar.mangar_dir}/public"
      paths.public.javascripts  "#{Mangar.mangar_dir}/public/javascripts"
      paths.public.stylesheets  "#{Mangar.mangar_dir}/public/stylesheets"

      config.instance_eval do
        def database_configuration
          db_connection = { :adapter => 'sqlite3', :database => "#{Mangar.mangar_dir}/db.sqlite3", :pool => 5,
           :timeout => 5000 }
          { 'development' => db_connection, 'production' => db_connection }
        end
      end
    end

    #This shouldn't be required - Rails should be using this application's #database_configuration method automatically/
    ActiveRecord::Base.configurations = Mangar::Application.config.database_configuration
    
    #After paths have reloaded
    
    if new_app
      Dir.mkdir(Mangar.mangar_dir)
      Dir.mkdir("#{Mangar.mangar_dir}/public")
    end
    
    #internally run the migrations on the app
    
    #NOTE: Removes files in Mangar.mangar_dir, if it's wrong could remove user files
    Dir.glob("#{Rails.root}/public/*").each { |f| FileUtils.rm_f("#{Mangar.mangar_dir}/#{File.basename(f)}") }
    FileUtils.ln_sf(Dir.glob("#{Rails.root}/public/*"), "#{Mangar.mangar_dir}/public")

    ActionDispatch::Callbacks.new(Proc.new {}, false).call({})
    #...

    #reload middleware so that paths.public etc. get reloaded
    #Also, clear any caches etc.
    #(external to this method, but important: redirect the user to / so the user sees the new books)
  end

  mattr_accessor :dir, :mangar_dir
end

Mangar.setup(".media/Yotsuba/Manga") #TODO REMOVE <================================================

Time::DATE_FORMATS.merge!(:default => '%e %B %Y') #TODO fix so shows time as well
Date::DATE_FORMATS.merge!(:default => '%e %B %Y')

require Rails.root.join('lib/file_extensions')