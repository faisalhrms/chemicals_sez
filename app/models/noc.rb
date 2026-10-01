class Noc < ApplicationRecord
  MAX_DOCUMENT_SIZE = 10.megabytes
  ALLOWED_CONTENT_TYPES = [ "application/pdf" ].freeze

  belongs_to :project
  belongs_to :created_by, class_name: "User"
  belongs_to :updated_by, class_name: "User"

  has_one_attached :document

  validates :description, presence: true, length: { maximum: 250 }
  validates :applied_on, presence: true
  validate :attained_date_not_before_applied_date
  validate :validate_document

  private

  def attained_date_not_before_applied_date
    return if attained_on.blank? || applied_on.blank? || attained_on >= applied_on

    errors.add(:attained_on, "cannot be before the applied date")
  end

  def validate_document
    return unless document.attached?

    errors.add(:document, "must be a PDF") unless pdf_file?(document)
    errors.add(:document, "must be 10 MB or smaller") if document.blob.byte_size > MAX_DOCUMENT_SIZE
  end
  def pdf_file?(attachment)
    ALLOWED_CONTENT_TYPES.include?(attachment.blob.content_type) &&
      attachment.filename.extension_without_delimiter.downcase == "pdf"
  end
end
