module Account
  class AppearancesController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user
      attributes = appearance_params

      unless valid_appearance_values?(attributes)
        redirect_to edit_account_appearance_path, alert: "Invalid appearance setting."
        return
      end

      if @user.update(attributes)
        AuditLogger.call(
          user: @user,
          auditable: @user,
          action: "appearance_updated",
          metadata: attributes.to_h
        )
        redirect_to edit_account_appearance_path, notice: "Appearance settings saved."
      else
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def appearance_params
      params.require(:user).permit(:portal_layout, :theme_preference, :table_density)
    end

    def valid_appearance_values?(attributes)
      User.portal_layouts.key?(attributes[:portal_layout]) &&
        User.theme_preferences.key?(attributes[:theme_preference]) &&
        User.table_densities.key?(attributes[:table_density])
    end
  end
end
