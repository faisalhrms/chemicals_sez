class CreateDevelopmentReportItems < ActiveRecord::Migration[8.1]
  def change
    create_table :development_report_items do |t|
      t.references :development_report, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :development_category, null: false, foreign_key: { on_delete: :restrict }, index: false
      t.decimal :completion_percentage, precision: 5, scale: 2
      t.date :expected_completion_on
      t.text :delay_reason
      t.text :support_required
      t.timestamps
    end

    add_index :development_report_items,
      [ :development_report_id, :development_category_id ],
      unique: true,
      name: "index_report_items_on_report_and_category"

    add_check_constraint :development_report_items,
      "completion_percentage IS NULL OR (completion_percentage >= 0 AND completion_percentage <= 100)",
      name: "development_report_items_completion_range"
  end
end
