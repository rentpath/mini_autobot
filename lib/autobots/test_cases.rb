
require 'bundler'

envs = [:default]
envs << ENV['AUTOBOT_ENV'].to_sym if ENV.has_key?('AUTOBOT_ENV')
Bundler.require(*envs)

require 'autobots/test_case'

module Autobots

  # An empty container for actual test cases and test classes.
  module TestCases
  end

end

