lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mini_autobot/version'

Gem::Specification.new do |s|
  s.name          = "mini_autobot"
  s.version       = MiniAutobot::VERSION
  s.authors       = ["Ripta Pasay", "Peijie Hu", "RentPath"]

  s.summary       = %q{Web automation framework on minitest, selenium webdriver, and page objects.}
  s.description   = %q{Wrapper of minitest and selenium-webdriver that supports multiple webapps
                          and multiple OS/browser ui automation testing, ready to be integrated in
                          development pipeline with jenkins and saucelabs.}
  s.homepage      = "https://github.com/rentpath/autobots"
  s.license       = "MIT"

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = "bin"
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '~> 4.2'
  s.add_dependency 'faker', '~> 1.4'
  s.add_dependency 'minitap', '~> 0.5.3'
  s.add_dependency 'pry', '~> 0.10'
  s.add_dependency 'minitest', '~>5.4.0'
  s.add_dependency 'selenium-webdriver', '~> 2.46'
  s.add_dependency 'rest-client', '~> 1.8'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.3.0'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-minitest'
  s.add_development_dependency 'yard'
end
