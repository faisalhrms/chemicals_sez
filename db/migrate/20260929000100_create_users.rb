class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false, limit: 120
      t.string :email_address, null: false, limit: 255
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :users, "LOWER(email_address)", unique: true, name: "index_users_on_lower_email"
    add_index :users, :role
    add_check_constraint :users, "role IN (0, 1, 2)", name: "users_role_check"
  end
end
