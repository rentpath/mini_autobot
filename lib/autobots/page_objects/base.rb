require "selenium-webdriver"
require "test/unit"
require "yaml"

class Autobots::PageObjects::Base

  def initialize(driver)
    @driver = driver
  end

end
      
