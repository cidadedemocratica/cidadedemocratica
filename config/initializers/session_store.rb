# Be sure to restart your server when you modify this file.

# Cidadedemocratica::Application.config.session_store :cookie_store, :key => '_cidadedemocratica_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Cidadedemocratica::Application.config.session_store :active_record_store

require 'action_dispatch/middleware/session/dalli_store'
Rails.application.config.session_store :dalli_store,
  :namespace => 'sessions',
  :key => '_cidadedemocratica_session'
