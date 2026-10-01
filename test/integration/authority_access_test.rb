require "test_helper"

class AuthorityAccessTest < ActionDispatch::IntegrationTest
  test "authority sees approved report but not under review report" do
    approved = build_report(Date.new(2026, 9, 14), :approved)
    under_review = build_report(Date.new(2026, 9, 20), :under_review)
    sign_in_authority

    get authority_development_report_path(approved)
    assert_response :success

    get authority_development_report_path(under_review)
    assert_response :not_found
  end

  private

  def build_report(date, status)
    DevelopmentReport.create!(
      project: projects(:sapphire),
      reporting_month: date.beginning_of_month,
      report_date: date,
      created_by: users(:submitter),
      submitted_by: users(:submitter),
      submitted_at: Time.current,
      reviewed_by: (users(:reviewer) if status == :approved),
      approved_at: (Time.current if status == :approved),
      status: status
    )
  end

  def sign_in_authority
    post session_path, params: {
      email_address: users(:authority).email_address,
      password: "StrongPassword!123",
      workspace: "authority"
    }
  end
end
