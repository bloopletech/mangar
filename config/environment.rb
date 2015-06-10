# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Mangar::Application.initialize!

#Mangar::Application::DATABASE_PATH = "#{Mangar.mangar_dir}/db.sqlite3"

#ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :pool => 100, :timeout => 5000, :database => Mangar::Application::DATABASE_PATH)
#ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate/")

#%w(open gnome-open).detect { |app| system("#{app} http://localhost:30813/") } unless $0 =~ /^rake|irb$/
