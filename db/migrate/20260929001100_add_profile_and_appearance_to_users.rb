class AddProfileAndAppearanceToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :phone, :string, limit: 40
    add_column :users, :job_title, :string, limit: 120
    add_column :users, :portal_layout, :integer, null: false, default: 0
    add_column :users, :theme_preference, :integer, null: false, default: 1
    add_column :users, :table_density, :integer, null: false, default: 0

    add_check_constraint :users, "portal_layout IN (0, 1)", name: "users_portal_layout_check"
    add_check_constraint :users, "theme_preference IN (0, 1, 2)", name: "users_theme_preference_check"
    add_check_constraint :users, "table_density IN (0, 1)", name: "users_table_density_check"
  end
end
