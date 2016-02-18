module MiniAutobot

  class GoogleSheets
    require 'rubygems'
    require 'google/api_client'
    require 'google_drive'
    require 'json'

    def initialize
      @session = session
      @worksheet = worksheet
    end

    def session
      GoogleDrive.saved_session(MiniAutobot.root.join(MiniAutobot.root, '/config/mini_autobotgoogle_drive_config.json'))
    end

    def worksheet
      @session.spreadsheet_by_key(MiniAutobot.settings.google_sheet).worksheets[0]
    end

  end
end
