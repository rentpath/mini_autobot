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
    def update_cells(args)
      ws = worksheet(args[:page])
      if args[:domcontentloaded]
        perf_col = performance_metric_column('DOMContentLoaded', ws)
        first_blank = row_of_first_blank_cell_in_column(perf_col, ws)
        ws[first_blank, perf_col] = args[:domcontentloaded]
        ws[first_blank, (perf_col + 1)] = Time.now()
      end
      ws.save
    end

    private

    def worksheet(page)
      browser = page.driver.browser
      browser_name = nil
      case browser
      when /chrome/
        browser_name = 'Chrome'
      when /firefox/
        browser_name = 'Firefox'
      when /internet_explorer/
        browser_name = 'IE'
      end
      page_name = page.class.name.split('::').last
      worksheets = @spreadsheet.worksheets
      worksheets.find { |worksheet| worksheet.title == "#{browser_name} #{page_name}" }
    end

    # Determines which column the values for the specified metric are being reported to
    def performance_metric_column(metric, ws)
      (1..ws.num_cols).find { |col| ws[1, col] == metric }
    end

    def row_of_first_blank_cell_in_column(column, ws)
      row = (1..ws.num_rows).find { |row| ws[row, column].to_s.empty? }
      if row.nil?
        row = ws.num_rows + 1
      end
      row
    end

  end
end
