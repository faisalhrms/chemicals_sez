class DevelopmentReport < ApplicationRecord
  MAX_DOCUMENT_SIZE = 10.megabytes
  ALLOWED_CONTENT_TYPES = [ "application/pdf" ].freeze

  belongs_to :project
  belongs_to :source_report,
    class_name: "DevelopmentReport",
    optional: true
  belongs_to :created_by, class_name: "User"
  belongs_to :submitted_by, class_name: "User", optional: true
  belongs_to :reviewed_by, class_name: "User", optional: true

  has_many :items,
    -> { joins(:development_category).order("development_categories.position") },
    class_name: "DevelopmentReportItem",
    dependent: :destroy,
    inverse_of: :development_report

  has_many :audit_events, as: :auditable, dependent: :restrict_with_exception

  has_one_attached :attachment

  accepts_nested_attributes_for :items

  before_update :prevent_approved_report_changes, if: -> { status_was == "approved" }
  before_destroy :prevent_approved_report_destruction, if: :approved?

  enum :status, {
    draft: 0,
    under_review: 1,
    reverted: 2,
    approved: 3
  }, default: :draft, validate: true

  validates :reporting_month, :report_date, presence: true
  validates :review_comment, length: { maximum: 2_000 }, allow_blank: true
  validate :reporting_month_is_first_day
  validate :report_date_matches_reporting_month
  validate :validate_attachment

  scope :latest_first, -> { order(report_date: :desc, created_at: :desc) }
  scope :for_month, ->(month) { where(reporting_month: month.beginning_of_month) }

  def editable?
    draft? || reverted?
  end

  def reporting_month_label
    reporting_month.strftime("%B %Y")
  end

  private

  def prevent_approved_report_changes
    errors.add(:base, "Approved reports are immutable")
    throw :abort
  end

  def prevent_approved_report_destruction
    errors.add(:base, "Approved reports cannot be deleted")
    throw :abort
  end

  def reporting_month_is_first_day
    return if reporting_month.blank? || reporting_month.day == 1

    errors.add(:reporting_month, "must be the first day of the selected month")
  end

  def report_date_matches_reporting_month
    return if report_date.blank? || reporting_month.blank?
    return if report_date.beginning_of_month == reporting_month

    errors.add(:report_date, "must fall within the selected reporting month")
  end

  def validate_attachment
    return unless attachment.attached?

    errors.add(:attachment, "must be a PDF") unless pdf_file?(attachment)
    errors.add(:attachment, "must be 10 MB or smaller") if attachment.blob.byte_size > MAX_DOCUMENT_SIZE
  end
  def pdf_file?(attachment)
    ALLOWED_CONTENT_TYPES.include?(attachment.blob.content_type) &&
      attachment.filename.extension_without_delimiter.downcase == "pdf"
  end
end
