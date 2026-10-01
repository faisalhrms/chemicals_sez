class Session < ApplicationRecord
  belongs_to :user

  validates :ip_address, length: { maximum: 64 }, allow_blank: true
  validates :user_agent, length: { maximum: 500 }, allow_blank: true

  scope :recent, -> { where("created_at >= ?", 12.hours.ago) }
end
