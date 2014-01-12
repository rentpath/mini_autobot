
module Autobots

  # This is the overarching module that contains page objects, modules, and
  # widgets. 
  #
  # When new modules or classes are added, an `autoload` clause must be added
  # into this module so that requires are taken care of automatically.
  module PageObjects

    class InvalidePageState < Exception
    end

    # Autoloads for major classes and modules
    autoload :Base,       'autobots/page_objects/base'
    autoload :Overlays,   'autobots/page_objects/overlays'
    autoload :Widgets,    'autobots/page_objects/widgets'

    # Autoloads for page modules and components
    autoload :Common,         'autobots/page_objects/common'
    autoload :MainFooter,     'autobots/page_objects/main_footer'
    autoload :MainNavigation, 'autobots/page_objects/main_navigation'

    # Autoloads for page objects
    autoload :Home,               'autobots/page_objects/home'
    autoload :Search,             'autobots/page_objects/search'
    autoload :PropertyDetails,    'autobots/page_objects/property_details'
    autoload :PropertySelection,  'autobots/page_objects/property_selection'
    autoload :LeaseReportPage1,   'autobots/page_objects/lease_report_page1'

  end

end


