require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test
task :test => :spec

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) { |r| r.verbose = false }
rescue LoadError
  puts '==> no rspec available'
end
