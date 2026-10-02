require "test_helper"
require "zip"

class ExcelExportTest < ActionDispatch::IntegrationTest
  setup do
    @report = DevelopmentReports::CreateDraft.call(project: projects(:sapphire), user: users(:submitter),
      reporting_month: Date.new(2026, 9, 1), report_date: Date.new(2026, 9, 14))
    @report.items.first.update!(completion_percentage: 34.25)
    @report.update!(status: :approved, approved_at: Time.current)
    post session_path, params: { email_address: users(:authority).email_address,
      password: "StrongPassword!123", workspace: "authority" }
  end

  test "authority downloads a valid backend generated XLSX attachment" do
    get export_authority_development_report_path(@report)
    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.media_type
    assert_includes response.headers["Content-Disposition"], "attachment"
    assert_includes response.headers["Content-Disposition"], "DSR_2026_09_2026_09_14.xlsx"
    assert_includes response.headers["Cache-Control"], "no-store"
    Zip::File.open_buffer(StringIO.new(response.body)) do |zip|
      assert zip.find_entry("xl/worksheets/sheet1.xml")
      assert zip.find_entry("xl/styles.xml")
    end
  end

  test "authority cannot export an unapproved report" do
    draft = DevelopmentReports::CreateDraft.call(project: projects(:sapphire), user: users(:submitter),
      reporting_month: Date.new(2026, 9, 1), report_date: Date.new(2026, 9, 15))
    get export_authority_development_report_path(draft)
    assert_response :not_found
  end
end
