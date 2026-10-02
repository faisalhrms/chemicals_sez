module Developer
  class DevelopmentReportsController < BaseController
    before_action :set_report, only: %i[show edit update submit_for_review download_attachment]

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

    def new
      @report = current_project.development_reports.build
      authorize @report
    end

    def create
      authorize current_project.development_reports.build
      month = Date.strptime(params.require(:reporting_month), "%Y-%m").beginning_of_month
      report_date = Date.iso8601(params.require(:report_date))

      @report = DevelopmentReports::CreateDraft.call(
        project: current_project,
        user: Current.user,
        reporting_month: month,
        report_date: report_date
      )

      redirect_to edit_developer_development_report_path(@report), notice: "Draft created using the latest approved figures where available."
    rescue ArgumentError, ActiveRecord::RecordInvalid => error
      redirect_to new_developer_development_report_path, alert: error.message
    end

    def edit
      authorize @report
    end

    def update
      authorize @report
      if @report.update(report_params)
        AuditLogger.call(user: Current.user, auditable: @report, action: "draft_updated")
        redirect_to edit_developer_development_report_path(@report), notice: "Draft saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def submit_for_review
      authorize @report, :submit_for_review?
      DevelopmentReports::SubmitForReview.call(report: @report, user: Current.user)
      redirect_to developer_development_reports_path(month: @report.reporting_month.strftime("%Y-%m")),
        status: :see_other, notice: "Report submitted for review."
    rescue ArgumentError, ActiveRecord::RecordInvalid => error
      redirect_to edit_developer_development_report_path(@report), alert: error.message
    end

    def download_attachment
      authorize @report, :download_attachment?
      send_private_pdf(@report.attachment)
    end

    private

    def set_report
      @report = current_project.development_reports.find(params[:id])
    end

    def report_params
      params.require(:development_report).permit(
        :attachment,
        items_attributes: %i[id completion_percentage expected_completion_on delay_reason support_required]
      )
    end

    def parse_month(value)
      return if value.blank?

      Date.strptime(value, "%Y-%m").beginning_of_month
    rescue Date::Error
      nil
    end
  end
end
