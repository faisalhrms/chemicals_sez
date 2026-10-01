require "test_helper"

class ProjectEditingTest < ActionDispatch::IntegrationTest
  test "developer can update project details" do
    sign_in(users(:submitter), "developer")

    patch developer_project_path, params: {
      section: "project-overview",
      project: {
        project_name: "Updated Soda Ash Project",
        project_capacity: "250 KTPA"
      }
    }

    assert_redirected_to developer_project_path(anchor: "project-overview")
    project = projects(:sapphire).reload
    assert_equal "Updated Soda Ash Project", project.project_name
    assert_equal "250 KTPA", project.project_capacity
  end

  test "authority cannot update project details" do
    sign_in(users(:authority), "authority")

    patch developer_project_path, params: {
      project: { project_name: "Unauthorized Change" }
    }

    assert_redirected_to authority_root_path
    assert_not_equal "Unauthorized Change", projects(:sapphire).reload.project_name
  end

  private

  def sign_in(user, workspace)
    post session_path, params: {
      email_address: user.email_address,
      password: "StrongPassword!123",
      workspace: workspace
    }
  end
end
