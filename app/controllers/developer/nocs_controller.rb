module Developer
  class NocsController < BaseController
    before_action :set_noc, only: %i[update download]

    def create
      @noc = current_project.nocs.build(noc_params)
      @noc.created_by = Current.user
      @noc.updated_by = Current.user
      authorize @noc

      if @noc.save
        AuditLogger.call(user: Current.user, auditable: @noc, action: "noc_created")
        redirect_to developer_project_path(anchor: "nocs"), notice: "NOC saved."
      else
        redirect_to developer_project_path(anchor: "nocs"), alert: @noc.errors.full_messages.to_sentence
      end
    end

    def update
      authorize @noc
      @noc.updated_by = Current.user

      if @noc.update(noc_params)
        AuditLogger.call(user: Current.user, auditable: @noc, action: "noc_updated")
        redirect_to developer_project_path(anchor: "nocs"), notice: "NOC updated."
      else
        redirect_to developer_project_path(anchor: "nocs"), alert: @noc.errors.full_messages.to_sentence
      end
    end

    def download
      authorize @noc, :download?
      return redirect_to developer_project_path(anchor: "nocs"), alert: "No document is attached." unless @noc.document.attached?

      send_private_pdf(@noc.document)
    end

    private

    def set_noc
      @noc = current_project.nocs.find(params[:id])
    end

    def noc_params
      params.require(:noc).permit(:description, :applied_on, :attained_on, :document)
    end
  end
end
