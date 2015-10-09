require 'json'
require 'pry'

tests = ["test_homedup", "test_home1", "test_homedup",  "test_srp", "test_srp1"]

def save_to_ever_failed(name)
  ever_failed_tests = 'ever_failed_tests'
  File.open(ever_failed_tests, 'a') do |f|
    existing_failed_tests = File.readlines(ever_failed_tests).map do |line|
      line.delete "\n"
    end
    f.puts name unless existing_failed_tests.include? name
  end
end

def json_save_to_ever_failed(name)
  ever_failed_tests = 'ever_failed_tests.json'
  puts 'run once'
	File.open(ever_failed_tests, 'a+') do |file|
		if file.size == 0
			puts 'file empty'
			file.puts "{"
			file.puts "    \"#{name}\" : { \"rerun_count\" : 1 }"
			file.puts "}"
		else
	  	data_hash = JSON.parse file.read
			puts data_hash
		end
	end
end

tests.each do |test|
  # save_to_ever_failed test
  json_save_to_ever_failed test
end
