require "selenium-webdriver"
require "test/unit"
require 'autobots'
require 'autobots/page_objects'

class Autobots::PageObjects::Base

  def initialize(driver)
    @driver = driver
  end

  LINK_SIGNIN="//span[@id='signin-text']/span[2]"
  INPUT_EMAIL="email_form_input"
  INPUT_PASSOWORD="password"
  BUTTON_SIGNIN="sign-in-button"

  def sign_in
    @driver.find_element(:xpath, LINK_SIGNIN.click)
    @driver.find_element(:id, INPUT_EMAIL).send_keys @QA_USERNAME
    @driver.find_element(:id, INPUT_PASSOWORD).send_keys @QA_PASSWORD
    @driver.find_element(:id, BUTTON_SIGNIN).click
  end

  def register
  end

  def sign_out
  end

end
      
