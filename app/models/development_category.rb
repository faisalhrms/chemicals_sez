class DevelopmentCategory < ApplicationRecord
  has_many :development_report_items, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :active_ordered, -> { where(active: true).order(:position) }
end
