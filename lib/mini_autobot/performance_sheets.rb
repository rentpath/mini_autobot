module MiniAutobot

  # Class that supports integration with Google Sheets
  # See documentation here: https://developers.google.com/drive/v3/web/about-auth to set up OAuth 2.0
  # access to your sheets. Place the info in google_drive_config.json in your config/mini_autobot folder
  #
  # To use, use the -g or --google_sheets parameter with the id of your sheet
  # Example: -g 1gWbpPq7rrTdNtSJSN2ljDlPE-okf0w3w7ai5PlhY8bk
  class PerformanceSheets < GoogleSheets
    require 'rubygems'
    require 'google/api_client'
    require 'google_drive'
    require 'json'

    def initialize(args)
      @args = args
      @session = session
      @spreadsheet = spreadsheet
    end

    # Updates all cells with the value provided that have the corresponding key in the Automation Serial Column
    # At the end of your test, place the following line:
    # Example:
    # MiniAutobot.google_sheets.update_cells('Auto Pass', 'HP-1') if MiniAutobot.settings.google_sheets?
    def update_cells(page, metric, value)
      ws = worksheet(page)
      perf_col = performance_metric_column(metric, ws)
      first_blank = row_of_first_blank_cell_in_column(perf_col, ws)
      ws[first_blank, perf_col] = value
      ws.save
    end

    private

    def session
      GoogleDrive.saved_session(@args[:session])
    end

    def spreadsheet
      @session.spreadsheet_by_key(@args[:spreadsheet])
    end

    def worksheet(page)
      page_name = page.class.name.split('::').last
      worksheets = @spreadsheet.worksheets
      worksheet = worksheets.find { |worksheet| worksheet.title == page_name }
      worksheet
    end

    # Determines which column the values for the specified metric are being reported to
    def performance_metric_column(metric, ws)
      (1..ws.num_cols).find { |col| ws[1, col] == metric }
    end

    def row_of_first_blank_cell_in_column(column, ws)
      (1..ws.num_rows).find { |row| ws[row, column].empty? }
    end

  end
end
