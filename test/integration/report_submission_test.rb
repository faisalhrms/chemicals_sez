require "test_helper"

class ReportSubmissionTest < ActionDispatch::IntegrationTest
  setup do
    @report = DevelopmentReports::CreateDraft.call(project: projects(:sapphire), user: users(:submitter),
      reporting_month: Date.new(2026, 9, 1), report_date: Date.new(2026, 9, 14))
    @item = @report.items.first
    post session_path, params: { email_address: users(:submitter).email_address,
      password: "StrongPassword!123", workspace: "developer" }
  end

  test "submit for review saves all entered values without a separate draft save" do
    patch developer_development_report_path(@report), params: {
      intent: "submit_for_review", development_report: entered_values
    }
    assert_redirected_to developer_development_reports_path(month: "2026-09")
    assert @report.reload.under_review?
    assert_equal users(:submitter), @report.submitted_by
    assert_equal BigDecimal("34.25"), @item.reload.completion_percentage
    assert_equal Date.new(2026, 10, 17), @item.expected_completion_on
    assert_equal "Waiting for materials", @item.delay_reason
    assert_equal "Procurement assistance", @item.support_required
    assert_equal 1, @report.audit_events.where(action: "submitted_for_review").count
  end

  test "direct submission includes the optional PDF attachment" do
    Tempfile.create([ "report", ".pdf" ]) do |file|
      file.write("%PDF-1.4\n%%EOF\n")
      file.flush
      values = entered_values.merge(attachment: Rack::Test::UploadedFile.new(file.path, "application/pdf"))
      patch developer_development_report_path(@report), params: {
        intent: "submit_for_review", development_report: values
      }
      assert @report.reload.under_review?
      assert @report.attachment.attached?
      assert_equal "application/pdf", @report.attachment.blob.content_type
      assert_equal BigDecimal("34.25"), @item.reload.completion_percentage
    end
  end

  test "invalid values keep the draft editable and retain entered fields on the page" do
    values = entered_values
    values[:items_attributes]["0"][:completion_percentage] = "101"
    patch developer_development_report_path(@report), params: {
      intent: "submit_for_review", development_report: values
    }
    assert_response :unprocessable_entity
    assert @report.reload.draft?
    assert_nil @item.reload.completion_percentage
    assert_nil @report.submitted_at
    assert_select 'input[value="Waiting for materials"]'
    assert_select 'input[value="Procurement assistance"]'
    assert_select 'button[name="intent"]', text: "Submit for Review"
  end

  test "save draft saves entered data without submitting or requesting confirmation" do
    patch developer_development_report_path(@report), params: { development_report: entered_values }
    assert_redirected_to edit_developer_development_report_path(@report)
    assert @report.reload.draft?
    assert_equal BigDecimal("34.25"), @item.reload.completion_percentage
  end

  test "dedicated submit endpoint also saves posted fields" do
    post submit_for_review_developer_development_report_path(@report), params: { development_report: entered_values }
    assert @report.reload.under_review?
    assert_equal "Procurement assistance", @item.reload.support_required
  end

  test "already submitted reports cannot be modified by a second submit" do
    DevelopmentReports::SubmitForReview.call(report: @report, user: users(:submitter))
    patch developer_development_report_path(@report), params: {
      intent: "submit_for_review", development_report: entered_values
    }
    assert_redirected_to root_path
    assert @report.reload.under_review?
    assert_nil @item.reload.completion_percentage
    assert_equal 1, @report.audit_events.where(action: "submitted_for_review").count
  end

  private

  def entered_values
    { items_attributes: { "0" => { id: @item.id, completion_percentage: "34.25",
      expected_completion_on: "2026-10-17", delay_reason: "Waiting for materials",
      support_required: "Procurement assistance" } } }
  end
end
