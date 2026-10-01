class DevelopmentReportItem < ApplicationRecord
  belongs_to :development_report, inverse_of: :items
  belongs_to :development_category

  validates :completion_percentage,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100
    },
    allow_nil: true
  validates :delay_reason, :support_required, length: { maximum: 1_000 }, allow_blank: true
  validates :development_category_id, uniqueness: { scope: :development_report_id }

  before_update :prevent_locked_report_changes
  before_destroy :prevent_locked_report_changes

  private

  def prevent_locked_report_changes
    return unless development_report.under_review? || development_report.approved?

    errors.add(:base, "Report items cannot change while the report is under review or approved")
    throw :abort
  end
end
