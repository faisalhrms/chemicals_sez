require "test_helper"

class WorkflowTest < ActionDispatch::IntegrationTest
  test "submitter submits and reviewer approves report" do
    sign_in(users(:submitter), "developer")

    assert_difference("DevelopmentReport.count", 1) do
      post developer_development_reports_path, params: {
        reporting_month: "2026-09",
        report_date: "2026-09-14"
      }
    end
    report = DevelopmentReport.order(:id).last
    assert_redirected_to edit_developer_development_report_path(report)

    post submit_for_review_developer_development_report_path(report)
    assert report.reload.under_review?
    assert_redirected_to developer_development_reports_path(month: "2026-09")

    delete session_path
    sign_in(users(:reviewer), "developer")

    post approve_developer_review_path(report)
    assert_redirected_to developer_reviews_path
    assert report.reload.approved?
    assert_equal users(:reviewer), report.reviewed_by
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
