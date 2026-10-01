module Developer
  class SubmissionRecordsController < BaseController
    def index
      authorize DevelopmentReport
      @month = parse_month(params[:month]) || Date.current.beginning_of_month
      @reports = policy_scope(current_project.development_reports)
        .where.not(status: :draft)
        .for_month(@month)
        .latest_first
    end

    def show
      @report = current_project.development_reports.find(params[:id])
      authorize @report
    end

    private

    def parse_month(value)
      return if value.blank?

      Date.strptime(value, "%Y-%m").beginning_of_month
    rescue Date::Error
      nil
    end
  end
end
