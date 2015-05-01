module Autobots

  # This is the overarching module that contains page objects, modules, and
  # widgets. 
  #
  # When new modules or classes are added, an `autoload` clause must be added
  # into this module so that requires are taken care of automatically.
  module PageObjects

    # Exception to capture validation problems when instantiating a new page
    # object. The message contains the page object being instantiated as well
    # as the original, underlying error message if any.
    class InvalidePageState < Exception
    end

    # Autoloads for major classes and modules
    autoload :Base,       'autobots/page_objects/base'
    autoload :Overlay,    'autobots/page_objects/overlay'
    autoload :Widgets,    'autobots/page_objects/widgets'

    # Autoloads for page modules and components
    autoload :Common,         'autobots/page_objects/common'
    autoload :MainFooter,     'autobots/page_objects/main_footer'
    autoload :MainNavigation, 'autobots/page_objects/main_navigation'
    autoload :CommonMobile,   'autobots/page_objects/common_mobile'

    # Autoloads for page objects
    autoload :Home,               'autobots/page_objects/home'
    autoload :Search,             'autobots/page_objects/search'
    autoload :PropertyDetails,    'autobots/page_objects/property_details'
    autoload :MyRent,             'autobots/page_objects/my_rent'
    autoload :Mbs,                'autobots/page_objects/mbs'
    autoload :SearchBy,           'autobots/page_objects/search_by'
    autoload :MovingCenter1,       'autobots/page_objects/moving_center1'
    autoload :SiteMap,            'autobots/page_objects/site_map'
    autoload :FbSignin,           'autobots/page_objects/fb_signin'
    autoload :GplusSignin,        'autobots/page_objects/gplus_signin'
    autoload :CityGuide,          'autobots/page_objects/city_guide'
    autoload :Brochure,           'autobots/page_objects/brochure'
    autoload :MovingCenter2,       'autobots/page_objects/moving_center2'

    # Autoloads for page objects mobile
    autoload :HomeMobile,         'autobots/page_objects/home_mobile'
    autoload :SearchMobile,       'autobots/page_objects/search_mobile'
    
  end

end


