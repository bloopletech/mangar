# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mangar_session',
  :secret      => '58c02b804597ae2383abb8bce7bba97c6a0d05b0e3ad7fa9541261974bad05803ff0bd5822dec43ed1c9df99e77edddf7d21cd5af45766b7c58ba0cc69105515'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
