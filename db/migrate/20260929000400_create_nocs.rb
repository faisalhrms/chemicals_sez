class CreateNocs < ActiveRecord::Migration[8.1]
  def change
    create_table :nocs do |t|
      t.references :project, null: false, foreign_key: { on_delete: :restrict }
      t.string :description, null: false, limit: 250
      t.date :applied_on, null: false
      t.date :attained_on
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :updated_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.timestamps
    end

    add_index :nocs, [ :project_id, :applied_on ]
  end
end
