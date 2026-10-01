module Authority
  class CommitteeMeetingsController < BaseController
    def download
      meeting = current_project.committee_meetings.find(params[:id])
      authorize meeting, :download?
      return redirect_to authority_project_path(anchor: "committee-meetings"), alert: "No minutes are attached." unless meeting.minutes.attached?

      send_private_pdf(meeting.minutes)
    end
  end
end
