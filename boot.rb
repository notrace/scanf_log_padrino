# Defines our constants
RACK_ENV = ENV['RACK_ENV'] ||= 'development'  unless defined?(RACK_ENV)
XIUKE_ENV = ENV['RACK_ENV']
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)
# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, RACK_ENV)

##
# ## Enable devel logging
#
# Padrino::Logger::Config[:development][:log_level]  = :devel
# Padrino::Logger::Config[:development][:log_static] = true
#
# ## Configure your I18n
#
# I18n.default_locale = :en
# I18n.enforce_available_locales = false
#
# ## Configure your HTML5 data helpers
#
# Padrino::Helpers::TagHelpers::DATA_ATTRIBUTES.push(:dialog)
# text_field :foo, :dialog => true
# Generates: <input type="text" data-dialog="true" name="foo" />
#
# ## Add helpers to mailer
#
# Mail::Message.class_eval do
#   include Padrino::Helpers::NumberHelpers
#   include Padrino::Helpers::TranslationHelpers
# end

##
# Add your before (RE)load hooks here
#
Padrino.before_load do
  I18n.default_locale = 'zh_cn'
  # Time.zone = "Beijing"
  # ActiveRecord::Base.default_timezone = :local
  # ActiveRecord::Base.time_zone_aware_attributes = false

  # ActiveRecord::Base.default_timezone = :utc
  # ActiveRecord::Base.time_zone_aware_attributes = true
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
end


Padrino.require_dependencies "#{Padrino.root}/config/initializers/*.rb"


SCANF_DATA = Redis.new(:host => REDIS_CONFIG['host'], :port => 6379)
SCANF_DATA.select(5)


Padrino.load!
