class AuditEvent < ApplicationRecord
  belongs_to :user
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true, length: { maximum: 100 }

  def readonly?
    persisted?
  end
end
