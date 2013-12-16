source 'http://rubygems.org'

gem 'rails', '3.2.13'

gem 'activeadmin'
gem 'acts_as_commentable_with_threading'
gem 'acts_as_list'
gem 'acts_as_state_machine', :git => 'https://github.com/Codeminer42/acts_as_state_machine.git'
gem 'acts-as-taggable-on'
gem 'acts_as_tree', '0.2.0'
gem 'capistrano'
gem 'carrierwave'
gem 'chosen-rails'
gem 'dalli'
gem 'devise'
gem 'devise-encryptable'
gem 'dynamic_form'
gem 'fastercsv'
gem 'galetahub-salty_slugs', :require => 'salty_slugs', :git => 'git://github.com/akitaonrails/salty_slugs.git'
gem 'in_place_editing'
gem 'inherited_resources'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'json', '1.7.7', :platforms => [:ruby_18]
gem 'memcache-client'
gem 'meta-tags', :require => 'meta_tags'
gem 'mini_magick', '~> 3.5.0'
gem 'multi_json'
gem 'mysql2', '~> 0.3.11'
gem 'ncri_attachment_fu', :require => 'attachment_fu'
gem 'nested_form'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'prototype_legacy_helper', '0.0.0', :git => 'git://github.com/rails/prototype_legacy_helper.git'
gem 'prototype-rails'
gem 'rabl'
gem 'rails_autolink'
gem 'rails-settings', :require => 'settings'
gem 'recaptcha', :require => 'recaptcha/rails', :git => "git://github.com/ambethia/recaptcha.git"
gem 'redcarpet'
gem 'resque', :require => 'resque/server'
gem 'resque_mailer', '~> 1.0.1'
gem 'simplecov', :require => false, :group => :test
gem 'simple_enum'
gem 'simple_form'
gem 'system_timer', :platform => 'ruby_18'
gem 'virtus'
gem 'yajl-ruby', :platforms => [:ruby_19]
gem 'whenever', :require => false
gem 'will_paginate'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  # https://github.com/gregbell/active_admin/issues/1939
  gem 'coffee-script-source', '~> 1.4.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  gem 'turbo-sprockets-rails3'

  gem 'uglifier', '>= 1.0.3'
end

group :staging, :development do
  gem 'letter_opener_web', '~> 1.0'
end

group :production do
  gem 'newrelic_rpm', '~> 3.5.8.72'
end

group :development do
  gem 'brakeman'
  gem 'fuubar'
  gem 'pry-rails'
  gem 'thin'

  gem "bullet", "~> 4.5.0"

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'

  gem 'rb-fsevent'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'

  gem 'ruby-debug', :platform => 'ruby_18'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'forgery'
  gem 'rspec-rails'
  gem 'shoulda-matchers'

  gem 'capybara'
  gem 'capybara-email'
  gem 'poltergeist'
  gem 'database_cleaner'
end
