# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Mangar::Application.initialize!

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "#{MANGAR_DIR}/db.sqlite3", :pool => 5, :timeout => 5000)

#Possible bug in carrier_wave? Should we have to set BookPreviewUploader.root ourselves?
BookPreviewUploader.root = CarrierWave.root = Rails.public_path

#%w(open gnome-open).detect { |app| system("#{app} http://localhost:30813/") } unless $0 =~ /^rake|irb$/