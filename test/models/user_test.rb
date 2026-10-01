require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "developer workspace groups submitter and reviewer roles" do
    assert_equal "developer", users(:submitter).workspace
    assert_equal "developer", users(:reviewer).workspace
    assert_equal "authority", users(:authority).workspace
  end

  test "password must be at least twelve characters" do
    user = User.new(name: "Test", email_address: "new@example.com", password: "short", role: :developer_submitter)
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 12 characters)"
  end
end

class UserAppearanceTest < ActiveSupport::TestCase
  test "appearance preferences have safe defaults" do
    user = User.new(
      name: "Preference Test",
      email_address: "preferences@example.com",
      password: "StrongPassword!123",
      role: :developer_submitter
    )

    assert user.classic_sidebar?
    assert user.theme_light?
    assert user.density_comfortable?
  end
end
