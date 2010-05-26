require 'rubygems'

require 'net/http' #GOD DAMN YOU BUNDLER - requiring this here fixes wierd require problem later on when bundle is locked. Hopefully this is the only one we need to do this for.

# Set up gems listed in the Gemfile.
if File.exist?(File.expand_path('../../Gemfile', __FILE__))
  require 'bundler'
  Bundler.setup
end
