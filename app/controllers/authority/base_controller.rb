module Authority
  class BaseController < ApplicationController
    before_action :require_authority
    after_action :verify_authorized, unless: -> { controller_name == "dashboard" }

    private

    def require_authority
      return if Current.user&.authority?

      redirect_to developer_root_path, alert: "Authority workspace access is required."
    end

    def current_project
      @current_project ||= Project.order(:id).first!
    end
  end
end
