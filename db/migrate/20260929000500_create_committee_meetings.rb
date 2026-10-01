class CreateCommitteeMeetings < ActiveRecord::Migration[8.1]
  def change
    create_table :committee_meetings do |t|
      t.references :project, null: false, foreign_key: { on_delete: :restrict }
      t.string :committee_name, null: false, limit: 200
      t.date :meeting_on, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :updated_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.timestamps
    end

    add_index :committee_meetings, [ :project_id, :meeting_on ]
  end
end
