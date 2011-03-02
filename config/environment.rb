$KCODE = "utf8"
ENV['RAILS_ENV'] ||= 'development'
ENV['INDEX_ONLY'] = 'true'

RAILS_GEM_VERSION = '2.3.10' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')

require 'yaml'
require 'erb'
raw_config = File.read("#{RAILS_ROOT}/config/config.yml")
erb_config = ERB.new(raw_config).result
APP_CONFIG = YAML.load(erb_config)[RAILS_ENV]

require File.join(File.dirname(__FILE__), 'boot')
Rails::Initializer.run do |config|
  config.frameworks -= [ :active_resource ]

  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.active_record.observers = :comment_observer, :message_observer, :photo_observer

  config.action_view.sanitized_allowed_tags = ['strong', 'em', 'del', 'b', 'br', 'i', 'p', 'h2','h3','h4','h5','h6', 'img', 'li', 'ul', 'ol']
  config.action_view.sanitized_allowed_attributes = ['id', 'class', 'style']

#  config.gem 'jammit'
#  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx', :version => '>= 1.3.13'
#  config.gem 'will_paginate', :version => '2.3.12'
#  config.gem 'mbleigh-subdomain-fu', :source => 'http://gems.github.com', :lib => 'subdomain-fu'
#  config.gem 'russian', :lib => 'russian', :source => 'http://gems.github.com'  
#  config.gem 'RedCloth', :lib => "redcloth"
#  config.gem 'hpricot'
#  config.gem 'memcache-client', :lib => 'memcache'
#  config.gem 'ym4r'
#  config.gem "geokit"
#  #config.gem 'i18n', :version => '0.3.0'

  config.i18n.load_path = config.i18n.load_path + Dir[File.join(RAILS_ROOT,  'locales', '*.{rb,yml}')]
  config.i18n.default_locale = APP_CONFIG['default_lang']

  config.action_mailer.raise_delivery_errors = false
  config.time_zone = 'UTC'
  
  config.active_record.schema_format = :rb
  config.action_controller.session_store = :active_record_store
  #config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache/"
  config.cache_store = :mem_cache_store, { :namespace => APP_CONFIG['domain'] }
end

Rails.cache.instance_variable_get(:@data).reset if Rails.cache.class == ActiveSupport::Cache::MemCacheStore
Tag.delimiter = ' '

require 'fileutils'
