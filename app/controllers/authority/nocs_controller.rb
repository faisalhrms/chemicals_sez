module Authority
  class NocsController < BaseController
    def download
      noc = current_project.nocs.find(params[:id])
      authorize noc, :download?
      return redirect_to authority_project_path(anchor: "nocs"), alert: "No document is attached." unless noc.document.attached?

      send_private_pdf(noc.document)
    end
  end
end
