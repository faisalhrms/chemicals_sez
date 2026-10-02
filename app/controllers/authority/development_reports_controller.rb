module Authority
  class DevelopmentReportsController < BaseController
    before_action :set_report, only: %i[show export download_attachment]

    def index
      authorize DevelopmentReport
      @month = parse_month(params[:month]) || Date.current.beginning_of_month
      scope = policy_scope(current_project.development_reports).for_month(@month).latest_first
      @listing = ReportListing.new(scope, params)
      @reports = @listing.records
    end

    def show
      authorize @report
    end

    def export
      authorize @report, :export?
      filename = "DSR_#{@report.reporting_month.strftime('%Y_%m')}_#{@report.report_date.strftime('%Y_%m_%d')}.xlsx"
      response.headers["Cache-Control"] = "private, no-store"
      response.headers["Pragma"] = "no-cache"

      send_data DevelopmentReports::ExcelExporter.new(@report).to_stream.read,
        filename: filename,
        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        disposition: "attachment"
    end

    def download_attachment
      authorize @report, :download_attachment?
      send_private_pdf(@report.attachment)
    end

    private

    def set_report
      @report = policy_scope(current_project.development_reports).find(params[:id])
    end

    def parse_month(value)
      return if value.blank?

      Date.strptime(value, "%Y-%m").beginning_of_month
    rescue Date::Error
      nil
    end
  end
end
