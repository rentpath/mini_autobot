require 'bundler/setup'

envs = [:default]
envs << ENV['AUTOBOT_BUNDLE'].to_sym if ENV.key?('AUTOBOT_BUNDLE')
envs << ENV['APPLICATION_ENV'].to_sym if ENV.key?('APPLICATION_ENV')

Bundler.setup(*envs)
require 'minitest'
require 'yaml'
require 'erb'
require 'faker'
require 'selenium/webdriver'
require 'rest-client'

require 'cgi'
require 'pathname'

require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/attr_internal'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/conversions'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/with_options'
require 'active_support/core_ext/string/access'
require 'active_support/core_ext/string/conversions'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/starts_ends_with'
require 'active_support/core_ext/string/strip'
require 'active_support/inflector'
require 'active_support/logger'

require_relative 'minitap/minitest5_rent'

ActiveSupport::Inflector.inflections(:en) do |inflector|
  inflector.acronym 'PDP'
  inflector.acronym 'SRP'
end

Time::DATE_FORMATS[:month_day_year] = "%m/%d/%Y"

require_relative 'mini_autobot/init'
