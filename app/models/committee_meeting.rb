class CommitteeMeeting < ApplicationRecord
  MAX_DOCUMENT_SIZE = 10.megabytes
  ALLOWED_CONTENT_TYPES = [ "application/pdf" ].freeze

  belongs_to :project
  belongs_to :created_by, class_name: "User"
  belongs_to :updated_by, class_name: "User"

  has_one_attached :minutes

  validates :committee_name, presence: true, length: { maximum: 200 }
  validates :meeting_on, presence: true
  validate :validate_minutes

  private

  def validate_minutes
    return unless minutes.attached?

    errors.add(:minutes, "must be a PDF") unless pdf_file?(minutes)
    errors.add(:minutes, "must be 10 MB or smaller") if minutes.blob.byte_size > MAX_DOCUMENT_SIZE
  end
  def pdf_file?(attachment)
    ALLOWED_CONTENT_TYPES.include?(attachment.blob.content_type) &&
      attachment.filename.extension_without_delimiter.downcase == "pdf"
  end
end
