module Account
  class ProfilesController < ApplicationController
    def show
      @user = current_user
    end

    def update
      @user = current_user
      @user.assign_attributes(profile_params)

      if @user.save
        @user.avatar.purge if params[:remove_avatar] == "1" && @user.avatar.attached?
        AuditLogger.call(user: @user, auditable: @user, action: "profile_updated")
        redirect_to account_profile_path, notice: "Profile updated successfully."
      else
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :show, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:user).permit(:name, :phone, :job_title, :avatar)
    end
  end
end
