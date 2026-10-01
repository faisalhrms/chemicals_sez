module Account
  class PasswordsController < ApplicationController
    rate_limit to: 5, within: 15.minutes, only: :update,
      with: -> { redirect_to edit_account_password_path, alert: "Too many password attempts. Please try again later." }

    def edit
      @user = current_user
    end

    def update
      @user = current_user

      unless @user.authenticate(params[:current_password].to_s)
        flash.now[:alert] = "Current password is incorrect."
        render :edit, status: :unprocessable_entity
        return
      end

      if @user.update(password_params)
        @user.sessions.where.not(id: Current.session.id).delete_all
        AuditLogger.call(user: @user, auditable: @user, action: "password_changed")
        redirect_to account_profile_path, notice: "Password changed successfully. Other signed-in sessions were closed."
      else
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def password_params
      params.permit(:password, :password_confirmation)
    end
  end
end
