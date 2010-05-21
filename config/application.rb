require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

#Set up manga dir
DIR = ENV['DIR']

unless DIR
  puts <<-EOF
Please run this application like so:

~$ DIR=<your manga directory> rails server -e production -p 30813

So if you stored your manga in ~/Pictures/Manga/<manga name>/*.jpg, you would run:

~$ DIR=~/Pictures/Manga/ rails server -e production -p 30813

EOF
  exit
end

MANGAR_DIR = "#{DIR}/.mangar"

new_app = !File.exists?(MANGAR_DIR)

if new_app
  Dir.mkdir(MANGAR_DIR)
  Dir.mkdir("#{MANGAR_DIR}/public")
end

require 'fileutils'

#NOTE: Removes files in MANGAR_DIR, if it's wrong could remove user files
Dir.glob("#{Rails.root}/public/*").each { |f| FileUtils.rm_f("#{MANGAR_DIR}/#{File.basename(f)}") }
#~ FileUtils.ln_sf(Dir.glob("#{Rails.root}/public/*"), "#{MANGAR_DIR}/public")

#More special config

ActsAsTaggableOn::TagList.delimiter = ' '

module Mangar
  class Application < Rails::Application
    paths.public              "#{MANGAR_DIR}/public"
    paths.public.javascripts  "#{MANGAR_DIR}/public/javascripts"
    paths.public.stylesheets  "#{MANGAR_DIR}/public/stylesheets"

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
end

Time::DATE_FORMATS.merge!(:default => '%e %B %Y') #TODO fix so shows time as well
Date::DATE_FORMATS.merge!(:default => '%e %B %Y')

require Rails.root.join('lib/file_extensions')

`rake db:migrate` if new_app