module Developer
  class ReviewsController < BaseController
    before_action :set_report, only: %i[show approve revert]
    before_action :require_reviewer, only: %i[approve revert]

    def index
      authorize DevelopmentReport, :index?
      scope = policy_scope(current_project.development_reports)

      if Current.user.reviewer?
        @pending_reports = scope.under_review.where.not(submitted_by_id: Current.user.id).latest_first
        @reviewed_reports = scope.where(reviewed_by_id: Current.user.id).where(status: %i[approved reverted]).latest_first
      else
        @pending_reports = scope.where(submitted_by_id: Current.user.id, status: :under_review).latest_first
        @reviewed_reports = scope.where(submitted_by_id: Current.user.id, status: %i[approved reverted]).latest_first
      end
      @pending_listing = ReportListing.new(@pending_reports, params, prefix: "pending_")
      @reviewed_listing = ReportListing.new(@reviewed_reports, params, prefix: "reviewed_")
      @pending_reports = @pending_listing.records
      @reviewed_reports = @reviewed_listing.records
    end

    def show
      authorize @report, :review_center_show?
    end

    def approve
      authorize @report, :approve?
      DevelopmentReports::Review.call(
        report: @report,
        reviewer: Current.user,
        decision: :approve,
        comment: params[:comment]
      )
      redirect_to developer_reviews_path, notice: "Report approved and forwarded to Authority."
    rescue ArgumentError, ActiveRecord::RecordInvalid => error
      redirect_to developer_review_path(@report), alert: error.message
    end

    def revert
      authorize @report, :revert?
      DevelopmentReports::Review.call(
        report: @report,
        reviewer: Current.user,
        decision: :revert,
        comment: params[:comment]
      )
      redirect_to developer_reviews_path, notice: "Report reverted to the submitter."
    rescue ArgumentError, ActiveRecord::RecordInvalid => error
      redirect_to developer_review_path(@report), alert: error.message
    end

    private

    def require_reviewer
      return if Current.user.reviewer?

      redirect_to developer_reviews_path, alert: "Approve/revert permission is required."
    end

    def set_report
      @report = current_project.development_reports.find(params[:id])
    end
  end
end
