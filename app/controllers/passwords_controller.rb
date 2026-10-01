class PasswordsController < ApplicationController
  layout "authentication"
  allow_unauthenticated_access
  rate_limit to: 5, within: 10.minutes, only: :create, with: -> { redirect_to new_password_path, notice: generic_notice }

  before_action :set_user_by_token, only: %i[edit update]

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address].to_s.strip.downcase, active: true)
    PasswordsMailer.reset(user).deliver_now if user

    redirect_to new_session_path, notice: generic_notice
  end

  def edit
  end

  def update
    if @user.update(password_params)
      @user.sessions.delete_all
      redirect_to new_session_path, notice: "Password updated. Please sign in again."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_token_for(:password_reset, params[:token])
    return if @user&.active?

    redirect_to new_password_path, alert: "This password reset link is invalid or has expired."
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def generic_notice
    "If the account exists, password reset instructions will be sent."
  end
end
