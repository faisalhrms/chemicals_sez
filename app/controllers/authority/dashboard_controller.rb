module Authority
  class DashboardController < BaseController
    def index
      @project = current_project
      @recent_reports = current_project.development_reports.approved.latest_first.limit(5)
    end
  end
end
