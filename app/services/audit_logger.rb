class AuditLogger
  def self.call(user:, auditable:, action:, metadata: {})
    AuditEvent.create!(
      user: user,
      auditable: auditable,
      action: action,
      metadata: metadata
    )
  end
end
