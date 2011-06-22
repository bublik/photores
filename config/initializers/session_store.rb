# Be sure to restart your server when you modify this file.

#Photores::Application.config.session_store :active_record_store, :key => '_photores_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")

Photores::Application.config.session_store :active_record_store
Photores::Application.config.session = {
  :domain => ".#{APP_CONFIG['domain']}",
  :expire_after => 14.days,
  :domain => :all
}

