# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Mangar::Application.initialize!

#Possible bug in carrier_wave? Should we have to set BookPreviewUploader.root ourselves?
BookPreviewUploader.root = CarrierWave.root = Rails.public_path

#%w(open gnome-open).detect { |app| system("#{app} http://localhost:30813/") } unless $0 =~ /^rake|irb$/

Mangar.configure(Collection.most_recently_used) if Collection.most_recently_used && File.exists?(Collection.most_recently_used.path)