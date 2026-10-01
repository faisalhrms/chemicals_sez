require "test_helper"

class DevelopmentReports::ReviewTest < ActiveSupport::TestCase
  setup do
    @report = DevelopmentReports::CreateDraft.call(
      project: projects(:sapphire),
      user: users(:submitter),
      reporting_month: Date.new(2026, 9, 1),
      report_date: Date.new(2026, 9, 14)
    )
    DevelopmentReports::SubmitForReview.call(report: @report, user: users(:submitter))
  end

  test "reviewer can approve another users submission" do
    DevelopmentReports::Review.call(report: @report, reviewer: users(:reviewer), decision: :approve)
    assert @report.reload.approved?
    assert_equal users(:reviewer), @report.reviewed_by
  end

  test "revert requires a comment" do
    error = assert_raises(ArgumentError) do
      DevelopmentReports::Review.call(report: @report, reviewer: users(:reviewer), decision: :revert, comment: "")
    end
    assert_equal "A comment is required when reverting", error.message
  end

  test "submitter cannot review own submission" do
    error = assert_raises(ArgumentError) do
      DevelopmentReports::Review.call(report: @report, reviewer: users(:submitter), decision: :approve)
    end
    assert_match(/Only reviewers|own submission/, error.message)
  end
  test "a stale second review cannot change an already reviewed report" do
    stale_copy = DevelopmentReport.find(@report.id)

    DevelopmentReports::Review.call(
      report: @report,
      reviewer: users(:reviewer),
      decision: :revert,
      comment: "Please correct the figures."
    )

    error = assert_raises(ArgumentError) do
      DevelopmentReports::Review.call(
        report: stale_copy,
        reviewer: users(:reviewer),
        decision: :approve
      )
    end

    assert_equal "Report is not under review", error.message
  end
end
