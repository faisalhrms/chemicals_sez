class SessionsController < ApplicationController
  layout "authentication"
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Too many sign-in attempts. Please try again shortly." }

  def new
    redirect_to workspace_root_for(Current.user) if authenticated?
  end

  def create
    user = User.find_by(email_address: params[:email_address].to_s.strip.downcase)
    workspace = params[:workspace].to_s

    if valid_login?(user, workspace)
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: "Signed in successfully."
    else
      redirect_to new_session_path(workspace: workspace.presence), alert: "Invalid email, password, or workspace."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other, notice: "Signed out successfully."
  end

  private

  def valid_login?(user, workspace)
    user&.active? &&
      user.workspace == workspace &&
      user.authenticate(params[:password].to_s)
  end
end
