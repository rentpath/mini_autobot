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

tests.each do |test|
  save_to_ever_failed test
end
