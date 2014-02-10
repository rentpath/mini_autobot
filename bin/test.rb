require "json"
require "selenium-webdriver"
gem "minitest"
require "minitest/autorun"

class Smoke < Minitest::Test

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "http://www.stg.rent.com/"
    #@base_url = "http://qateam:wap88@www.qa.rent.com"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 5
    @email_address= "TEST"+Array.new(8){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join + "@rent.com"
    @verification_errors = []
    @search_zipcode='90405'
    @search_city="Santa Monica"
    @endeca_user="endeca-test@rent.com"
    @endeca_passowrd="endeca-test"
    @viva_user="viva-test1@rent.com"
    @viva_password="viva-test"

  end

  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end

  def login(pick=nil)
    if pick=="endeca"
      user=@endeca_user
      password=@endeca_passowrd
    else
      user=@viva_user
      password=@viva_password
      end
    @driver.get(@base_url)
    sleep 2
    @driver.find_element(:id, "signin-text").click
    @driver.find_element(:css, "#ar-signin-form > ul.unstyled > li.clear-fix > #email_form_input").clear
    @driver.find_element(:css, "#ar-signin-form > ul.unstyled > li.clear-fix > #email_form_input").send_keys user
    @driver.find_element(:id, "ar-u-password").clear
    @driver.find_element(:id, "ar-u-password").send_keys password
    @driver.find_element(:css, "#ar-signin-form > ul.unstyled > li.clear-fix > button.btn.btn-primary-action").click

  end


  #Test Login
  def test_a_login
      puts "testing login"
      login("endeca")
      assert_equal @driver.find_element(:css, '.acct-email').text, @endeca_user
  end

  #Test advanced search multiple options selected
  def test_multiple_filter_search
    @driver.get(@base_url + "/search/results?displayMode=search&page=1&location=90405&SortType=19&propertyTypes=Apartment&propertyTypes=Condominium&propertyTypes=Townhome&floorPlanTypes=2&bathroomTypes=&minRent=100&maxRent=5000&minSqFtAmt=100&petPolicy=0%7C0&unitFeatures=&bldgFeatures=&areas=&searchRadius=25&restrictionTypes=none&propertyKeywords=")
    @driver.find_element(:css, "#results-filter-beds > summary").click
    @driver.find_element(:id, "beds-3").click
    @driver.find_element(:id, "results-filter-submit-bottom").click
    @driver.find_element(:css, "details.rent-range-filter > summary").click
    @driver.find_element(:id, "maxRent").click
    # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
    @driver.find_element(:css, "#maxRent > option[value=\"2000\"]").click
    @driver.find_element(:id, "results-filter-submit-top").click
    @driver.find_element(:css, "#results-filter-petpolicy > summary > div.details-toggle > span.icon.i-triangle-right-blue").click
    @driver.find_element(:id, "pets-none").click
    @driver.find_element(:id, "results-filter-submit-top").click
    @driver.find_element(:id, "results-filter-submit-bottom").click
    # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
    #assert_equal "$1275", @driver.find_element(:css, "#53751781 > div.prop-info > p.prop-rent").text
    assert_equal "3", @driver.find_element(:css, "p.prop-beds-baths-pets > span.prop-beds > span").text
  end


  #Test zip-code search
  def test_zipcode_search
    @driver.get(@base_url + "/search/results?displayMode=search&location=#{@search_zipcode}&minRent=100&sortType=19")
    @driver.find_element(:css, "#results-filter-beds > summary > div.details-toggle > span.icon.i-triangle-right-blue").click
    @driver.find_element(:id, "beds-3").click
    @driver.find_element(:css, "#results-filter-senior > summary").click
    @driver.find_element(:id, "restricted-senior").click
    @driver.find_element(:id, "restricted-income").click
    @driver.find_element(:id, "results-filter-submit-bottom").click
    assert_includes @driver.title, @search_zipcode
  end


   #Test city and go to pdp to verify
  def test_city_search
    @driver.get(@base_url + "/")
    #@driver.find_element(:css, "button.btn.cancel").click
    @driver.find_element(:id, "freeform_submarket_nm").clear
    @driver.find_element(:id, "freeform_submarket_nm").send_keys @search_city
    @driver.find_element(:css, "button.btn.cancel").click
    sleep 4
    @driver.find_elements(:css, "img")[2].click
    sleep 4
   assert_includes(@driver.title,@search_city)
   end

  #Test floorplan
  def test_floorplan
    @driver.get(@base_url + "/california/hermosa-beach-apartments/playa-pacifica-4-436109")
    @driver.find_element(:css, "dl.priority1.fp-plan > dd").click
    assert_equal "", @driver.find_element(:xpath, "(//img[@alt='floor plan image'])[2]").text
    @driver.find_element(:link, "A2").click
    assert_equal "", @driver.find_element(:css, "img[alt=\"floor plan image\"]").text
  end

  #Test signin from /moving-center
  def test_signin
    @driver.get(@base_url + "/moving-center/")
    @driver.find_element(:id, "signin-text").click
    @driver.find_element(:css, "#ar-signin-form > ul.unstyled > li.clear-fix > #email_form_input").clear
    @driver.find_element(:css, "#ar-signin-form > ul.unstyled > li.clear-fix > #email_form_input").send_keys @viva_user
    @driver.find_element(:id, "ar-u-password").clear
    @driver.find_element(:id, "ar-u-password").send_keys @viva_password
    @driver.find_element(:css, "#ar-signin-form > ul.unstyled > li.clear-fix > button.btn.btn-primary-action").click
    assert_equal @driver.find_element(:css, '.acct-email').text, @viva_user
  end

  #Test My Rent Page logged out
  def mtest_my_rent_page
    @driver.get(@base_url + "/moving-center/")
    @driver.find_element(:link, "My Rent").click
    assert_equal "MyRent", @driver.title
  end

  #Test My Rent Page logged in
  def test_logged_my_rent_page
    login
    @driver.find_element(:link, "My Rent").click
    puts @driver.title
    assert_equal "MyRent", @driver.title
  end



  #Test CCS page
  def test_get_ccs_page(link_name=nil)
    @driver.get(@base_url + "/")
    @driver.find_element(:link, "US State").click
    @driver.find_element(:link, "Alabama").click
    assert_includes @driver.title, 'Alabama'
  end



  def test_reward_page
    @driver.get(@base_url + "/search/results")
    @driver.find_element(:link, "$100 Reward").click
    assert_includes @driver.title,  "100 Reward Card"
  end


  #def mtest_alt_registration
  #  @driver.get(@base_url + "/")
  #  @driver.find_element(:id, "freeform_submarket_nm").clear
  #  @driver.find_element(:id, "freeform_submarket_nm").send_keys "90278"
  #  @driver.find_element(:css, "button.btn.cancel").click
  #  sleep(2)
  #  properties=@driver.find_elements(:css, "img")
  #  properties[0].click
  #  #@driver.find_element(:link, "Next").click
  #  sleep 2
  #  @driver.find_element(:css, "#carousel-reg-form input").send_keys(@email_address)
  #  @driver.find_element(:xpath, "//input[@value='Create a Free Account']").click
  #  @driver.find_element(:id, "password").click
  #  sleep 4
  #  @driver.find_element(:id, "password").send_keys "sage"
  #  @driver.find_element(:link, "Submit").click
  #  assert_include( @driver.title,'Hermosa Beach',)
  #
  #end

  #Advanced search option for bedroom search
  def test_advanced_search_bedroom
    bedrooms=["beds-2" ]
     for  room in bedrooms
      @driver.get(@base_url + "/search/results?displayMode=search&location=90045&minRent=100&floorPlanTypes=0")
      @driver.find_element(:css, "#results-filter-beds > summary > div.details-toggle > span.icon.i-triangle-right-blue").click
      @driver.find_element(:id, room).click
      @driver.find_element(:id, "results-filter-submit-bottom").click
      sleep 4
      bedrooms_= (@driver.find_elements(:css,"p.prop-beds-baths-pets > span.prop-beds"))
      for b in bedrooms_
        puts (b.text), b[0]
        assert_includes(room.strip[5],((b.text).strip[0]))
      end
    end
  end

  #Test advanced search for pets
  def test_advanced_search_cats
    pets=["pets-cats-dogs", "pets-cats"]
    login
    for  pet in pets
      @driver.get(@base_url + "/search/results?displayMode=search&location=91367&minRent=100&floorPlanTypes=0")
      @driver.find_element(:css, "#results-filter-petpolicy > summary").click
      @driver.find_element(:id, pet).click
      @driver.find_element(:id, "results-filter-submit-bottom").click
      sleep 4
      pet_= (@driver.find_elements(:css,".i-cat"))
      for p in pet_
        puts (p.text)
        assert_includes((p.text),"Cats",)

      end
    end
  end

  #Test advanced search for dogs
  def mtest_advanced_search_dogs
    pets=["pets-dogs"]
    login
    for  pet in pets
      @driver.get(@base_url + "/search/results?displayMode=search&location=91367&minRent=100&floorPlanTypes=0")
      @driver.find_element(:css, "#results-filter-petpolicy > summary").click
      @driver.find_element(:id, pet).click
      @driver.find_element(:id, "results-filter-submit-bottom").click
      sleep 4
      pet_= (@driver.find_elements(:css,".i-dog"))
      for p in pet_
        puts (p.text)
        assert_includes((p.text),"Dogs",)

      end
    end
  end



  #Test no pets
  def test_advanced_search_no_pets
    pets=["pets-none"]
    for  pet in pets
      @driver.get(@base_url + "/search/results?displayMode=search&location=91367&minRent=100&floorPlanTypes=0")
      @driver.find_element(:css, "#results-filter-petpolicy > summary").click
      @driver.find_element(:id, pet).click
      @driver.find_element(:id, "results-filter-submit-bottom").click
      sleep 4
      pet_= (@driver.find_elements(:css,".prop-beds-baths-pets"))
      for p in pet_
        #puts (p.text)
        assert_not_equal((p.text),"Cats" || "Dogs")

      end
    end
  end

  def test_search_banding
    login
    sleep 2
    #@driver.navigate(@url+'/search/results/')
    @driver.get(@base_url+'/search/results/')
    @driver.find_element(:id, "search-near").clear
    @driver.find_element(:css,"#search-near").send_keys @search_zipcode
    @driver.find_element(:css, "button.btn.btn-search").click
    banding= @driver.find_element(:css,".results-section").text
    assert_includes(banding, "Properties" )

  end

  #THis test clicks on map icons, recursively. However, not complete yet.
   def test_map_based_search
  @driver.get(@base_url+'/california/hermosa-beach/apartments_condos_townhouses' )
  @driver.find_element(:css, "#srp-map-view > span.btn-text").click
  #@driver.find_element(:xpath, "//div[@id='map_canvas']/div/div/div/div[3]/div[2]/div[21]").click
  #@driver.find_element(:xpath, "(//img[contains(@src,'http://media-instart.rent.com/oneweb/img/icons-sd.png?v=01212014')])[6]").click
  #@driver.find_element(:xpath, "(//img[contains(@src,'http://media-instart.rent.com/oneweb/img/icons-sd.png?v=01212014')])[4]").click
  #assert_equal "Bayview Apartments", @driver.find_element(:css, "a.prop-name").text
  clusters= @driver.find_elements(:css, ".cluster-icon")
  #for c in clusters
  #  puts c.text
  puts  clusters[0].text
  clusters[0].click
  puts @driver.title

 end

  def test_altreg_lopdp
    @driver.get(@base_url + "/")
    @driver.find_element(:id, "freeform_submarket_nm").clear
    @driver.find_element(:id, "freeform_submarket_nm").send_keys "Anaheim, CA"
    @driver.find_element(:css, "button.btn.cancel").click
    @driver.find_element(:link, "Canyon Village").click
    sleep 5
    @driver.find_element(:css, "a.next").click
    sleep 5
    @driver.find_element(:xpath, "//input[@placeholder='Your email is never shared with third-parties']").send_keys @email_address
    sleep 5
    @driver.find_element(:xpath, "//input[@value='Create a Free Account']").click
    sleep 5
    password_field = @driver.find_element(:id, "password")
    password_field.clear
    password_field.send_keys @password
    sleep 5
    @driver.find_element(:link, "Submit").click
    expected_signin = @driver.find_element(:xpath => "//span[@class='acct-email']")
    assert_equal( expected_signin.text, @email_address )
    @driver.find_element(:css, "span.acct-email").click
    @driver.find_element(:link, "Sign Out").click
  end


  def test_check_availiability
    @driver.get(@base_url + "/search/results?location=Hermosa%20Beach%2C%20CA")
    @driver.find_element(:css, "#results-filter-unit-features > summary > div.details-toggle > span.icon.i-triangle-right-blue").click
    @driver.find_element(:id, "unit-feat-ac").click
    @driver.find_element(:id, "unit-feat-hardwood").click
    @driver.find_element(:id, "results-filter-submit-top").click
    @driver.find_element(:css, "img[alt=\"Archstone Playa del Rey - Playa Del Rey, California 90293\"]").click
    @driver.find_element(:link, "Property Details").click
    #@driver.find_element(:xpath, "(//a[contains(text(),'Check Availability')])[3]").click
    #sleep 3
    #@driver.find_element(:css, "ul.clear-fix.reg-elements > li > label > input[name=\"firstName\"]").clear
    #@driver.find_element(:css, "ul.clear-fix.reg-elements > li > label > input[name=\"firstName\"]").send_keys "sage"
    #@driver.find_element(:css, "ul.clear-fix.reg-elements > li.full-width > label > input[name=\"email\"]").clear
    #@driver.find_element(:css, "ul.clear-fix.reg-elements > li.full-width > label > input[name=\"email\"]").send_keys @email_address
    #@driver.find_element(:xpath, "(//button[@type='submit'])[8]").click
   end



  def mtest_get_ccs_page(link_name=nil)
    @driver.get(@base_url + "/")
    @driver.find_element(:link, "US State").click
    @driver.find_element(:link, "Alabama").click
    assert_includes @driver.title, 'Alabama'
  end


  def test_advanced_filters
    #Build a list of expected filter types in advanced filter
    @driver.get(@base_url + "/search/results")
    filters=['Property Type', 'Bedrooms', 'Bathrooms', 'Rent', 'Square Feet',
             'Pet Policy','Unit Features', 'Building Features', 'Neighborhoods',
             'Search Radius', 'Income Restricted','Property Name']
    @driver.get(@base_url+'/massachusetts/boston/apartments_condos_townhouses')
    #Get the values of the div of advanced filters
    get_filters=@driver.find_element(:css,".overlay-content")
    filters.each do |x|
      assert_includes get_filters.text, x
    end


  def test_forgot_password
    @driver.get(@base_url + "/california/playa-del-rey-apartments/archstone-playa-del-rey-4-426888#")
    @driver.find_element(:link, "< See all listings in Playa del Rey").click
    @driver.find_element(:css, "img[alt=\"Archstone Playa del Rey - Playa Del Rey, California 90293\"]").click
    @driver.find_element(:link, "Property Details").click
    sleep 3
    @driver.find_element(:xpath, "(//a[contains(text(),'Check Availability')])[2]").click
    sleep 2
    @driver.find_element(:id, "check-fname").clear
    @driver.find_element(:id, "check-fname").send_keys "test"
    @driver.find_element(:id, "check-lname").clear
    @driver.find_element(:id, "check-lname").send_keys "test"
    @driver.find_element(:id, "check-phone").clear
    @driver.find_element(:id, "check-phone").send_keys "(310) 993-8985"
    @driver.find_element(:link, "Edit").click
    @driver.find_element(:id, "first-name-overlay").clear
    @driver.find_element(:id, "first-name-overlay").send_keys "test"
    @driver.find_element(:id, "last-name-overlay").clear
    @driver.find_element(:id, "last-name-overlay").send_keys "test"
    @driver.find_element(:id, "phone-overlay").clear
    @driver.find_element(:id, "phone-overlay").send_keys "(310) 993-2871"
    @driver.find_element(:id, "confirm-password-overlay").clear
    @driver.find_element(:id, "confirm-password-overlay").send_keys "test"
    @driver.find_element(:name, "profile-form-save").click
    @driver.find_element(:link, "I forgot my password").click
    @driver.find_element(:name, "submit-email").click
    @driver.find_element(:css, "#forgot-password-overlay > div.overlay-hed > a.btn.btn-overlay-close").click
  end

  def test_chicago
    @driver.get(@base_url + "/")
    @driver.find_element(:link, "Chicago").click
    assert_includes @driver.title, "Chicago Apartments"
  end


  def test_sitemap
    @driver.get(@base_url + "/")
    @driver.find_element(:link, "Site Map").click
    @driver.find_element(:link, "Alabama").click
    @driver.find_element(:link, "Alabaster").click
    @driver.find_element(:link, "Montevallo Place").click
    assert_includes @driver.title, "Montevallo Place - Woodbrook Trail | Alabaster, AL Apartments for Rent"
  end




  def test_login
    self.login
  end




  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end

  def verify(&blk)
    yield
  rescue Test::Unit::AssertionFailedError => ex
    @verification_errors << ex
  end

  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
  end
  end
