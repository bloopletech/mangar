# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

DIR = ENV['DIR'] || '/Users/bloopletech/Pictures/Manga'
MANGAR_DIR = "#{DIR}/.mangar"

new_app = !File.exists?(MANGAR_DIR)

if new_app
  Dir.mkdir(MANGAR_DIR)
  Dir.mkdir("#{MANGAR_DIR}/public")
end

require 'fileutils'
FileUtils.ln_s(Dir.glob("#{RAILS_ROOT}/public/*"), "#{MANGAR_DIR}/public")

Rails.public_path = "#{MANGAR_DIR}/public"

#Sigh. This patch is only needed because rails-2.3.4/lib/rails/rack/static.rb uses RAILS_ROOT/public instead of Rails.public_path.
module Rails
  module Rack
    class Static
      def initialize(app)
        @app = app
        @file_server = ::Rack::File.new(Rails.public_path)
      end
    end
  end
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'will_paginate', :version => '2.3.12', :source => 'http://gemcutter.org'
  config.gem 'formtastic', :version => '0.9.7', :source => 'http://gemcutter.org'
  config.gem 'acts-as-taggable-on', :version => '1.1.6', :source => 'http://gemcutter.org'
  config.gem 'carrierwave', :version => '0.4.5', :source => 'http://gemcutter.org'
#  config.gem 'paperclip', :version => '2.3.1', :source => 'http://gemcutter.org'
#  config.gem 'directory_watcher', :version => '1.1.3', :source => 'http://gemcutter.org'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "#{MANGAR_DIR}/db.sqlite3", :pool => 5, :timeout => 5000)

require 'file_extensions'

TagList.delimiter = ' '

CarrierWave.root = Rails.public_path

`rake db:migrate` if new_app