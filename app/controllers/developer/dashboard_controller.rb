module Developer
  class DashboardController < BaseController
    def index
      @project = current_project
      @pending_reviews = if Current.user.reviewer?
        @project.development_reports.under_review.where.not(submitted_by_id: Current.user.id).count
      else
        @project.development_reports.under_review.where(submitted_by_id: Current.user.id).count
      end
    end
  end
end
