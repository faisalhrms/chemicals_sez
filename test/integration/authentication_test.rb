require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "developer can sign in only through developer workspace" do
    post session_path, params: {
      email_address: users(:submitter).email_address,
      password: "StrongPassword!123",
      workspace: "developer"
    }
    assert_redirected_to developer_root_path
  end

  test "workspace mismatch is rejected" do
    post session_path, params: {
      email_address: users(:authority).email_address,
      password: "StrongPassword!123",
      workspace: "developer"
    }
    assert_redirected_to new_session_path(workspace: "developer")
  end
  test "invalid password reset token redirects without raising" do
    get edit_password_path(token: "invalid-token")
    assert_redirected_to new_password_path
  end
end
