module DevelopmentReports
  class ExcelExporter
    def initialize(report)
      @report = report
    end

    def to_stream
      package = Axlsx::Package.new
      workbook = package.workbook

      header = workbook.styles.add_style(b: true, bg_color: "17356D", fg_color: "FFFFFF", alignment: { horizontal: :center })
      title = workbook.styles.add_style(b: true, sz: 14)
      percentage = workbook.styles.add_style(num_fmt: "0.00")

      workbook.add_worksheet(name: "Development Status") do |sheet|
        sheet.add_row [ "Sapphire Value Addition SEZ Development Status Report" ], style: title, types: [ :string ]
        sheet.add_row [ "Reporting Month", @report.reporting_month_label ], types: %i[string string]
        sheet.add_row [ "Report Date", @report.report_date.strftime("%d-%m-%Y") ], types: %i[string string]
        sheet.add_row [ "Status", @report.status.humanize ], types: %i[string string]
        sheet.add_row []
        sheet.add_row [ "Sr", "Description", "Completion %", "Expected Date of Completion", "Reasons for Delay", "Support Required" ], style: header

        @report.items.includes(:development_category).each_with_index do |item, index|
          sheet.add_row [
            index + 1,
            item.development_category.name,
            item.completion_percentage,
            item.expected_completion_on&.strftime("%d-%m-%Y"),
            item.delay_reason,
            item.support_required
          ],
            style: [ nil, nil, percentage, nil, nil, nil ],
            types: %i[integer string float string string string]
        end

        sheet.column_widths 6, 34, 16, 26, 34, 34
      end

      package.to_stream
    end
  end
end
