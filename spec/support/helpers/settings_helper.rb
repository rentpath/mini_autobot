module SettingsHelper

  def argv
    [  "-c",
       "saucelabs:phu:win7_chrome43",
       "-e",
       "rentpath_ci",
       "-n",
       "test_homepage_search"
    ]
  end

  def options
    {  
       :io=>#<IO:<STDOUT>>,
       :auto_finalize=>true,
       :console=>false,
       :reuse_driver=>false,
       :verbosity_level=>0,
       :parallel=>false,
       :connector=>"saucelabs:phu:win7_chrome43",
       :env=>"rentpath_ci",
       :filter=>"test_homepage_search",
       :seed=>3453,
       :args=> "-c saucelabs:phu:win7_chrome43 -e rentpath_ci -n test_homepage_search --seed 3453"
    }
  end

end
