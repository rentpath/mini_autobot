module MiniAutobot
  class Console < TestCase

    def self.bootstrap!
      MiniAutobot.settings.tags << [:__dummy__]
    end

    test :dummy, tags: [:__dummy__, :non_regression], serial: 'DUMMY' do
      require 'pry'
      assert_respond_to binding, :pry
      binding.pry
    end

  end
end
