require "test_helper"

class DevelopmentReportTest < ActiveSupport::TestCase
  test "multiple reports are allowed in the same reporting month" do
    first = create_report(Date.new(2026, 9, 3))
    second = create_report(Date.new(2026, 9, 14))

    assert first.persisted?
    assert second.persisted?
    assert_equal 2, DevelopmentReport.where(reporting_month: Date.new(2026, 9, 1)).count
  end

  test "report date must belong to reporting month" do
    report = DevelopmentReport.new(
      project: projects(:sapphire),
      reporting_month: Date.new(2026, 9, 1),
      report_date: Date.new(2026, 10, 3),
      created_by: users(:submitter)
    )

    assert_not report.valid?
    assert_includes report.errors[:report_date], "must fall within the selected reporting month"
  end

  private

  def create_report(report_date)
    DevelopmentReport.create!(
      project: projects(:sapphire),
      reporting_month: Date.new(2026, 9, 1),
      report_date: report_date,
      created_by: users(:submitter)
    )
  end
end
