require "test_helper"

class DevelopmentReports::CreateDraftTest < ActiveSupport::TestCase
  test "new draft copies values from latest approved report" do
    project = projects(:sapphire)
    submitter = users(:submitter)
    source = DevelopmentReports::CreateDraft.call(
      project: project,
      user: submitter,
      reporting_month: Date.new(2026, 8, 1),
      report_date: Date.new(2026, 8, 28)
    )
    source.items.first.update!(completion_percentage: 72)
    source.update!(status: :approved, approved_at: Time.current)

    draft = DevelopmentReports::CreateDraft.call(
      project: project,
      user: submitter,
      reporting_month: Date.new(2026, 9, 1),
      report_date: Date.new(2026, 9, 3)
    )

    assert_equal source.id, draft.source_report_id
    assert_equal 72, draft.items.first.completion_percentage
  end
end
