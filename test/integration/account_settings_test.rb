require "test_helper"

class AccountSettingsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:submitter)
    post session_path, params: {
      email_address: @user.email_address,
      password: "StrongPassword!123",
      workspace: "developer"
    }
  end

  test "user can switch portal layout and theme" do
    patch account_appearance_path, params: {
      user: {
        portal_layout: "modern_topbar",
        theme_preference: "dark",
        table_density: "compact"
      }
    }

    assert_redirected_to edit_account_appearance_path
    @user.reload
    assert @user.modern_topbar?
    assert @user.theme_dark?
    assert @user.density_compact?
  end

  test "user can update own profile but not role" do
    patch account_profile_path, params: {
      user: {
        name: "Updated User",
        phone: "+92 300 0000000",
        job_title: "Associate Officer",
        role: "authority"
      }
    }

    assert_redirected_to account_profile_path
    @user.reload
    assert_equal "Updated User", @user.name
    assert_equal "Associate Officer", @user.job_title
    assert @user.developer_submitter?
  end

  test "password change requires current password" do
    patch account_password_path, params: {
      current_password: "wrong-password",
      password: "AnotherStrongPassword!123",
      password_confirmation: "AnotherStrongPassword!123"
    }

    assert_response :unprocessable_entity
    assert @user.reload.authenticate("StrongPassword!123")
  end

  test "user can change password with current password" do
    patch account_password_path, params: {
      current_password: "StrongPassword!123",
      password: "AnotherStrongPassword!123",
      password_confirmation: "AnotherStrongPassword!123"
    }

    assert_redirected_to account_profile_path
    assert @user.reload.authenticate("AnotherStrongPassword!123")
  end
end
