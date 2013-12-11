require "selenium-webdriver"
require "test/unit"
require "yaml"
require 'autobots'
require 'autobots/page_objects'

class Autobots::PageObjects::Base

  def initialize(driver)
    @driver = driver
  end

end
      
