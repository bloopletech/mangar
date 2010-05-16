#require 'profile'
# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

#Set up manga dir
DIR = ENV['DIR']

unless DIR
  puts <<-EOF
Please run this application like so:

~$ DIR=<your manga directory> script/server -e production -p 30813

So if you stored your manga in ~/Pictures/Manga/<manga name>/*.jpg, you would run:

~$ DIR=~/Pictures/Manga/ script/server -e production -p 30813

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
Dir.glob("#{RAILS_ROOT}/public/*").each { |f| FileUtils.rm_f("#{MANGAR_DIR}/#{File.basename(f)}") }
FileUtils.ln_sf(Dir.glob("#{RAILS_ROOT}/public/*"), "#{MANGAR_DIR}/public")

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

#Normal rails init
Rails::Initializer.run do |config|
#  config.gem 'will_paginate', :version => '2.3.12'
#  config.gem 'formtastic', :version => '0.9.7'
  config.gem 'acts-as-taggable-on', :version => '1.1.6'
  config.gem 'carrierwave', :version => '0.4.5'
  config.gem 'rubyzip', :version => '0.9.4', :lib => false
#  config.gem 'paperclip', :version => '2.3.1'
#  config.gem 'directory_watcher', :version => '1.1.3'

  config.time_zone = 'UTC'
end

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "#{MANGAR_DIR}/db.sqlite3", :pool => 5, :timeout => 5000)

require 'file_extensions'

#Other config
TagList.delimiter = ' '

#Possible bug in carrier_wave? Should we have to set BookPreviewUploader.root ourselves?
BookPreviewUploader.root = CarrierWave.root = Rails.public_path

`rake db:migrate` if new_app

%w(open gnome-open).detect { |app| system("#{app} http://localhost:30813/") } unless $0 =~ /^rake|irb$/