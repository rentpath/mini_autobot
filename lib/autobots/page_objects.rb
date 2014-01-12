
module Autobots
  # This is the overarching module that contains page objects, modules, and
  # widgets. 
  #
  # When new modules or classes are added, an `autoload` clause must be added
  # into this module so that requires are taken care of automatically.
  module PageObjects

    autoload :Base,       'autobots/page_objects/base'
    autoload :Overlays,   'autobots/page_objects/overlays'
    autoload :Widgets,    'autobots/page_objects/widgets'

    autoload :MainNavigation,      'autobots/page_objects/main_navigation'

    autoload :Home,       'autobots/page_objects/home'
    autoload :Search,     'autobots/page_objects/search'
    autoload :PropertySelection, 'autobots/page_objects/property_selection'
    autoload :LrPage1,    'autobots/page_objects/lr_page1'
  end
end


