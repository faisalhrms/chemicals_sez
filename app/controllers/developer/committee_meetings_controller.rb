module Developer
  class CommitteeMeetingsController < BaseController
    before_action :set_meeting, only: %i[update download]

    def create
      @committee_meeting = current_project.committee_meetings.build(meeting_params)
      @committee_meeting.created_by = Current.user
      @committee_meeting.updated_by = Current.user
      authorize @committee_meeting

      if @committee_meeting.save
        AuditLogger.call(user: Current.user, auditable: @committee_meeting, action: "committee_meeting_created")
        redirect_to developer_project_path(anchor: "committee-meetings"), notice: "Committee meeting saved."
      else
        redirect_to developer_project_path(anchor: "committee-meetings"), alert: @committee_meeting.errors.full_messages.to_sentence
      end
    end

    def update
      authorize @committee_meeting
      @committee_meeting.updated_by = Current.user

      if @committee_meeting.update(meeting_params)
        AuditLogger.call(user: Current.user, auditable: @committee_meeting, action: "committee_meeting_updated")
        redirect_to developer_project_path(anchor: "committee-meetings"), notice: "Committee meeting updated."
      else
        redirect_to developer_project_path(anchor: "committee-meetings"), alert: @committee_meeting.errors.full_messages.to_sentence
      end
    end

    def download
      authorize @committee_meeting, :download?
      return redirect_to developer_project_path(anchor: "committee-meetings"), alert: "No minutes are attached." unless @committee_meeting.minutes.attached?

      send_private_pdf(@committee_meeting.minutes)
    end

    private

    def set_meeting
      @committee_meeting = current_project.committee_meetings.find(params[:id])
    end

    def meeting_params
      params.require(:committee_meeting).permit(:committee_name, :meeting_on, :minutes)
    end
  end
end
