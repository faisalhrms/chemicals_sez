class CreateAuditEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_events do |t|
      t.references :user, null: false, foreign_key: { on_delete: :restrict }
      t.string :auditable_type, null: false
      t.bigint :auditable_id, null: false
      t.string :action, null: false, limit: 100
      t.jsonb :metadata, null: false, default: {}
      t.datetime :created_at, null: false
    end

    add_index :audit_events, [ :auditable_type, :auditable_id, :created_at ], name: "index_audit_events_on_auditable_and_created_at"
    add_index :audit_events, :action
  end
end
