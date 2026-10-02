module DevelopmentReports
  class ExcelExporter
    TITLE = "Sapphire Value Addition Special Economic Zone Development Status Report".freeze
    COLUMN_WIDTHS = [ 6, 32, 30, 28, 40, 44 ].freeze
    BLUE = "4472C4".freeze
    ROW_COLORS = [ "E9EBF5", "CFD5EA" ].freeze

    def initialize(report)
      @report = report
    end

    def to_stream
      package = Axlsx::Package.new
      package.use_shared_strings = true
      workbook = package.workbook
      styles = report_styles(workbook.styles)

      workbook.add_worksheet(name: "Development Status", escape_formulas: true) do |sheet|
        sheet.add_row [ TITLE, nil, nil, nil, nil, nil ], style: styles[:title], height: 30
        sheet.merge_cells "A1:F1"
        sheet.add_row [
          "Sr\nNo", "Description", "Percentage Completion\nby #{@report.report_date.strftime('%d-%m-%Y')}",
          "Expected Date of\nCompletion", "Reasons\nfor Delay", "Support Required"
        ], style: [ styles[:serial], *Array.new(5, styles[:header]) ], height: 60

        @report.items.includes(:development_category).each_with_index do |item, index|
          values = [
            index + 1, item.development_category.name,
            item.completion_percentage&./(100), item.expected_completion_on,
            item.delay_reason, item.support_required
          ]
          row_styles = styles[:rows][index % 2]
          sheet.add_row values,
            style: [ styles[:serial], row_styles[:text], row_styles[:percentage], row_styles[:date], row_styles[:text], row_styles[:text] ],
            types: %i[integer string float date string string], height: row_height(values)
        end

        sheet.column_widths(*COLUMN_WIDTHS)
        sheet.sheet_view.show_grid_lines = false
        sheet.sheet_view.pane do |pane|
          pane.state = :frozen
          pane.y_split = 2
          pane.top_left_cell = "A3"
          pane.active_pane = :bottom_left
        end
        sheet.page_setup.orientation = :landscape
        sheet.page_setup.paper_size = 9 # A4
        sheet.page_setup.fit_to(width: 1, height: 0)
        sheet.print_options.horizontal_centered = true
        sheet.page_margins.set(left: 0.25, right: 0.25, top: 0.4, bottom: 0.4)
        sheet.header_footer.odd_footer = "&LReporting month: #{@report.reporting_month_label}&RPage &P of &N"
      end

      package.to_stream
    end

    private

    def report_styles(styles)
      common = { font_name: "Calibri", sz: 11, fg_color: "000000",
        border: { style: :thin, color: "FFFFFF", edges: :all },
        alignment: { vertical: :center, wrap_text: true } }
      {
        title: styles.add_style(common.merge(b: true, sz: 16, bg_color: BLUE, fg_color: "FFFFFF",
          alignment: { horizontal: :center, vertical: :center })),
        serial: styles.add_style(common.merge(b: true, bg_color: BLUE, fg_color: "FFFFFF",
          alignment: { horizontal: :center, vertical: :center, wrap_text: true })),
        header: styles.add_style(common.merge(bg_color: ROW_COLORS.last,
          alignment: { horizontal: :center, vertical: :bottom, wrap_text: true })),
        rows: ROW_COLORS.map do |color|
          body = common.merge(bg_color: color)
          {
            text: styles.add_style(body),
            percentage: styles.add_style(body.merge(format_code: "0.##%",
              alignment: { horizontal: :center, vertical: :center, wrap_text: true })),
            date: styles.add_style(body.merge(format_code: "dd-mm-yyyy",
              alignment: { horizontal: :center, vertical: :center, wrap_text: true }))
          }
        end
      }
    end

    def row_height(values)
      lines = values.each_with_index.map do |value, index|
        value.to_s.split("\n", -1).sum { |line| [ (line.length.to_f / (COLUMN_WIDTHS[index] * 0.85)).ceil, 1 ].max }
      end.max
      [ [ lines * 15 + 10, 28 ].max, 409 ].min
    end
  end
end
