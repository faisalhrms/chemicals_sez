require "test_helper"

class AuthorizationTest < ActionDispatch::IntegrationTest
  test "submitter can access review center to track own submissions" do
    sign_in(users(:submitter), "developer")
    get developer_reviews_path
    assert_response :success
  end

  test "submitter cannot approve a report" do
    report = DevelopmentReport.create!(
      project: projects(:sapphire),
      reporting_month: Date.new(2026, 9, 1),
      report_date: Date.new(2026, 9, 14),
      created_by: users(:reviewer),
      submitted_by: users(:reviewer),
      status: :under_review,
      submitted_at: Time.current
    )

    sign_in(users(:submitter), "developer")
    post approve_developer_review_path(report)
    assert_redirected_to developer_reviews_path
    assert report.reload.under_review?
  end

  test "authority cannot access developer workspace" do
    sign_in(users(:authority), "authority")
    get developer_root_path
    assert_redirected_to authority_root_path
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
