require "selenium-webdriver"
require "test/unit"
require "yaml"
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

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @properties= YAML.load_file('config.yaml')
    @URL=@properties['url']['qa']
    @QA_USERNAME=@properties['signin']['username']
    @QA_PASSWORD=@properties['signin']['password']

  end

  def teardown
    @driver.quit


   end


  def sign_in
    @driver.get(@URL)
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
      
