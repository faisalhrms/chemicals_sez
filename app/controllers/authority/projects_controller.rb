module Authority
  class ProjectsController < BaseController
    def show
      @project = current_project
      authorize @project
      @nocs = @project.nocs.order(applied_on: :desc)
      @committee_meetings = @project.committee_meetings.order(meeting_on: :desc)
      @recent_reports = @project.development_reports.approved.latest_first.limit(10)
    end
  end
end
