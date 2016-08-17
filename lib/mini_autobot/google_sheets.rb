module MiniAutobot

  # Class that supports integration with Google Sheets
  # See documentation here: https://developers.google.com/drive/v3/web/about-auth to set up OAuth 2.0
  # access to your sheets. Place the info in google_drive_config.json in your config/mini_autobot folder
  #
  # To use, use the -g or --google_sheets parameter with the id of your sheet
  # Example: -g 1gWbpPq7rrTdNtSJSN2ljDlPE-okf0w3w7ai5PlhY8bk
  class GoogleSheets
    require 'rubygems'
    require 'google/api_client'
    require 'google_drive'
    require 'json'

    def initialize(args)
      @args = args
      @session = session
      @spreadsheet = spreadsheet
      @worksheet = worksheet
      @automation_serial_column = automation_serial_column
      @selected_browser_column = selected_browser_column
    end

    # Updates all cells with the value provided that have the corresponding key in the Automation Serial Column
    # At the end of your test, place the following line:
    # Example:
    # MiniAutobot.google_sheets.update_cells('Auto Pass', 'HP-1') if MiniAutobot.settings.google_sheets?
    def update_cells(value, key)
      rows = target_rows(key)
      rows.each do |row|
        @worksheet[row, @selected_browser_column] = value
      end
      @worksheet.save
    end

    private

    def session
      GoogleDrive.saved_session(@args[:session])
    end

    def spreadsheet
      @session.spreadsheet_by_key(@args[:spreadsheet])
    end

    def worksheet
      environment_params = MiniAutobot.settings.env.split('_')
      environment_params[0].capitalize!
      environment_params[1].upcase!
      environment = environment_params[0] + ' ' + environment_params[1]
      worksheets = @spreadsheet.worksheets
      worksheet = worksheets.find { |worksheet| worksheet.title == environment }
      if worksheet.nil?
        worksheet = worksheets.find { |worksheet| worksheet.title == environment_params[1] }
      end
      worksheet
    end

    # Determines which column the keys are that define the link between your automated test cases
    # and the test cases in your Google Sheets spreadsheet
    def automation_serial_column
      (1..@worksheet.num_cols).find { |col| @worksheet[1, col] == 'Automation Serial Key' }
    end

    # This is the column where you record the results for a specific browser
    def selected_browser_column
      connector = MiniAutobot.settings.connector
      desired_browser_string = nil
      case connector
      when /chrome/
        desired_browser_string = 'Chrome (Automated)'
      when /ff/
        desired_browser_string = 'FF (Automated)'
      when /firefox/
        desired_browser_string = 'FF (Automated)'
      when /ie11/
        desired_browser_string = 'IE11 (Automated)'
      when /iphone/
        desired_browser_string = 'iPhone (Automated)'
      when /android/
        desired_browser_string = 'Android (Automated)'
      end
      column = (1..@worksheet.num_cols).find { |col| @worksheet[1, col] == desired_browser_string }
      if column.nil?
        create_column(desired_browser_string)
        column = (1..@worksheet.num_cols).find { |col| @worksheet[1, col] == desired_browser_string }
      end
      column
    end

    def create_column(desired_browser_string)
      @worksheet[1, (@worksheet.num_cols + 1)] = desired_browser_string
    end

    def target_rows(key)
      (1..@worksheet.num_rows).find_all { |row| @worksheet[row, @automation_serial_column] == key }
    end

  end
end
