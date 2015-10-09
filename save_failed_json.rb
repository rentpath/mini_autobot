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

# two approaches:
# 1. write to one file ever_failed_tests.json
# 2. write to individual files,
#    then merge all files data into one json file at the end of a run

# Approach 1
def json_save_to_ever_failed(name)
  ever_failed_tests = 'logs/tap_results/ever_failed_tests.json'
  data_hash = {}
  if File.file?(ever_failed_tests) && !File.zero?(ever_failed_tests)
  	data_hash = JSON.parse(File.read(ever_failed_tests))
  end
	if data_hash[name]
		data_hash[name]["rerun_count"] += 1
	else
		data_hash[name] = { "rerun_count" => 0 }
	end
	File.open(ever_failed_tests, 'w+') do |file|
		file.write JSON.pretty_generate(data_hash)
	end
end

tests.each do |test|
  # save_to_ever_failed test
  json_save_to_ever_failed test
end
