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
      @selected_browser_column = selected_browser_column
    end

    def session
      GoogleDrive.saved_session(MiniAutobot.root.join('config/mini_autobot', 'google_drive_config.json'))
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

    def selected_browser_column
      connector = MiniAutobot.settings.connector
      desired_browser_string = nil
      selected_browser_column = nil
      if connector.include?('chrome')
        desired_browser_string = 'Chrome'
      elsif connector.include?('ff')
        desired_browser_string = 'FF'
      elsif connector.include?('ie11')
        desired_browser_string = 'IE11'
      end
      (1..@worksheet.num_cols).each do |col|
        selected_browser_column = col if @worksheet[1, col] == desired_browser_string
      end
      selected_browser_column
    end

    def target_rows(key)
      rows = []
      (1..@worksheet.num_rows).each do |row|
        rows.push(row) if @worksheet[row, @automation_serial_column] == key
      end
      rows
    end

    def update_cells(value, key)
      rows = target_rows(key)
      rows.each do |row|
        @worksheet[row, @selected_browser_column] = value
      end
      @worksheet.save
    end

  end
end