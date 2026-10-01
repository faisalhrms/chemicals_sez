module Developer
  class ProjectsController < BaseController
    before_action :set_project

    def show
      authorize @project
      load_project_details
    end

    def update
      authorize @project

      if @project.update(project_params)
        AuditLogger.call(
          user: Current.user,
          auditable: @project,
          action: "project_updated",
          metadata: { section: params[:section].presence || "project_details" }
        )
        redirect_to developer_project_path(anchor: params[:section]), notice: "Project details saved successfully."
      else
        load_project_details
        flash.now[:alert] = @project.errors.full_messages.to_sentence
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_project
      @project = current_project
    end

    def load_project_details
      @nocs = @project.nocs.order(applied_on: :desc)
      @committee_meetings = @project.committee_meetings.order(meeting_on: :desc)
      @recent_reports = @project.development_reports.where.not(status: :draft).latest_first.limit(10)
      @noc = @project.nocs.build
      @committee_meeting = @project.committee_meetings.build
    end

    def project_params
      params.require(:project).permit(
        :zone_name, :zone_developer, :zone_type, :ownership_type, :notification_on,
        :total_zone_area, :zone_location, :zone_status, :regulatory_framework,
        :company_name, :company_incorporated_year,
        :project_name, :project_capacity, :project_location, :project_cost,
        :process_technology, :products, :raw_materials, :export_potential,
        :market_positioning, :employment_generation,
        :notice_to_proceed_on, :engineering_start_on, :engineering_end_on,
        :procurement_start_on, :procurement_end_on,
        :construction_start_on, :construction_end_on,
        :mechanical_completion_on, :commissioning_start_on,
        :commissioning_end_on, :commercial_operations_on
      )
    end
  end
end
