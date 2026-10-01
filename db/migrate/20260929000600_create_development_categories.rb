class CreateDevelopmentCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :development_categories do |t|
      t.string :name, null: false
      t.integer :position, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :development_categories, "LOWER(name)", unique: true, name: "index_development_categories_on_lower_name"
    add_index :development_categories, :position, unique: true
    add_check_constraint :development_categories, "position > 0", name: "development_categories_position_positive"
  end
end
