class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :ip_address, limit: 64
      t.string :user_agent, limit: 500
      t.timestamps
    end

    add_index :sessions, :created_at
  end
end
