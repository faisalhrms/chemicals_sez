module Developer
  class BaseController < ApplicationController
    before_action :require_developer
    after_action :verify_authorized, unless: -> { controller_name == "dashboard" }

    private

    def require_developer
      return if Current.user&.developer?

      redirect_to authority_root_path, alert: "Developer workspace access is required."
    end

    def current_project
      @current_project ||= Project.order(:id).first!
    end
  end
end
