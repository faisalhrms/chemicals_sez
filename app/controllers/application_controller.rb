class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_user

  private

  def current_user
    Current.user
  end

  def pundit_user
    Current.user
  end

  def user_not_authorized
    redirect_back fallback_location: root_path, alert: "You are not authorized to perform that action."
  end

  def send_private_pdf(attachment)
    response.headers["Cache-Control"] = "private, no-store"
    response.headers["Pragma"] = "no-cache"

    send_data attachment.download,
      filename: attachment.filename.to_s,
      type: "application/pdf",
      disposition: "attachment"
  end
end
