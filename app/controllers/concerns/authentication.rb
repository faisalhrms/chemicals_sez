module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    resume_session.present?
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    return Current.session if Current.session

    session_id = cookies.signed[:session_id]
    return unless session_id

    session_record = Session.recent.includes(:user).find_by(id: session_id)
    return terminate_session_record(session_record) if session_record && !session_record.user.active?

    Current.session = session_record
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.fullpath if request.get? || request.head?
    redirect_to new_session_path, alert: "Please sign in to continue."
  end

  def after_authentication_url
    stored_path = session.delete(:return_to_after_authenticating).to_s
    return stored_path if safe_local_path?(stored_path)

    workspace_root_for(Current.user)
  end

  def start_new_session_for(user)
    reset_session
    user.sessions.where("created_at < ?", 12.hours.ago).delete_all

    session_record = user.sessions.create!(
      user_agent: request.user_agent.to_s.first(500),
      ip_address: request.remote_ip.to_s.first(64)
    )

    Current.session = session_record
    cookies.signed[:session_id] = {
      value: session_record.id,
      expires: 12.hours.from_now,
      httponly: true,
      same_site: :lax,
      secure: request.ssl?
    }
  end

  def terminate_session
    Current.session&.destroy
    Current.session = nil
    cookies.delete(:session_id, secure: request.ssl?, httponly: true, same_site: :lax)
    reset_session
  end

  def terminate_session_record(record)
    record&.destroy
    cookies.delete(:session_id, secure: request.ssl?, httponly: true, same_site: :lax)
    nil
  end

  def safe_local_path?(path)
    path.start_with?("/") && !path.start_with?("//")
  end

  def workspace_root_for(user)
    user.authority? ? authority_root_path : developer_root_path
  end
end
