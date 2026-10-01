class User < ApplicationRecord
  AVATAR_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  AVATAR_EXTENSIONS = %w[jpg jpeg png webp].freeze
  MAX_AVATAR_SIZE = 3.megabytes

  has_secure_password
  has_one_attached :avatar

  has_many :sessions, dependent: :destroy
  has_many :created_reports,
    class_name: "DevelopmentReport",
    foreign_key: :created_by_id,
    inverse_of: :created_by,
    dependent: :restrict_with_exception

  enum :role, {
    developer_submitter: 0,
    developer_reviewer: 1,
    authority: 2
  }, default: :developer_submitter, validate: true

  enum :portal_layout, {
    classic_sidebar: 0,
    modern_topbar: 1
  }, default: :classic_sidebar, validate: true

  enum :theme_preference, {
    system: 0,
    light: 1,
    dark: 2
  }, default: :light, validate: true, prefix: :theme

  enum :table_density, {
    comfortable: 0,
    compact: 1
  }, default: :comfortable, validate: true, prefix: :density

  normalizes :email_address, with: ->(email) { email.strip.downcase }
  normalizes :phone, with: ->(phone) { phone.strip.presence }
  normalizes :job_title, with: ->(title) { title.strip.presence }

  validates :name, presence: true, length: { maximum: 120 }
  validates :email_address,
    presence: true,
    length: { maximum: 255 },
    format: { with: URI::MailTo::EMAIL_REGEXP },
    uniqueness: { case_sensitive: false }
  validates :phone, length: { maximum: 40 }, allow_blank: true
  validates :job_title, length: { maximum: 120 }, allow_blank: true
  validates :password, length: { minimum: 12 }, allow_nil: true
  validate :acceptable_avatar

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_digest.last(10)
  end

  def developer?
    developer_submitter? || developer_reviewer?
  end

  def reviewer?
    developer_reviewer?
  end

  def workspace
    authority? ? "authority" : "developer"
  end

  private

  def acceptable_avatar
    return unless avatar.attached?

    blob = avatar.blob
    extension = avatar.filename.extension_without_delimiter.to_s.downcase
    unless AVATAR_CONTENT_TYPES.include?(blob.content_type) && AVATAR_EXTENSIONS.include?(extension)
      errors.add(:avatar, "must be a JPG, PNG, or WebP image")
    end

    if blob.byte_size > MAX_AVATAR_SIZE
      errors.add(:avatar, "must be smaller than 3 MB")
    end
  end
end
