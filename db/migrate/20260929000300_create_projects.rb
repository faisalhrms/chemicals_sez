class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :zone_name, null: false
      t.string :zone_developer, null: false
      t.string :zone_type
      t.string :ownership_type
      t.date :notification_on
      t.string :total_zone_area
      t.string :zone_location
      t.string :zone_status
      t.string :regulatory_framework

      t.string :company_name
      t.integer :company_incorporated_year

      t.string :project_name, null: false
      t.string :project_capacity
      t.string :project_location
      t.string :project_cost
      t.string :process_technology
      t.text :products
      t.text :raw_materials
      t.string :export_potential
      t.text :market_positioning
      t.string :employment_generation

      t.date :notice_to_proceed_on
      t.date :engineering_start_on
      t.date :engineering_end_on
      t.date :procurement_start_on
      t.date :procurement_end_on
      t.date :construction_start_on
      t.date :construction_end_on
      t.date :mechanical_completion_on
      t.date :commissioning_start_on
      t.date :commissioning_end_on
      t.date :commercial_operations_on
      t.timestamps
    end
  end
end
