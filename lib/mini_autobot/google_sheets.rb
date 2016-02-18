module MiniAutobot

  class GoogleSheets
    require 'rubygems'
    require 'google/api_client'
    require 'google_drive'
    require 'json'

    def initialize
      @session = session
      @worksheet = worksheet
      @automation_serial_column = automation_serial_column
    end

    def session
      GoogleDrive.saved_session(MiniAutobot.root.join('config/mini_autobot, google_drive_config.json'))
    end

    def worksheet
      @session.spreadsheet_by_key(MiniAutobot.settings.google_sheet).worksheets[0]
    end

    def automation_serial_column
      automation_serial_column = 0
      (1..@worksheet.num_cols).each do |col|
        automation_serial_column = col if @worksheet[1, col] == 'Automation Serial Key'
      end
      automation_serial_column
    end

  end
end
