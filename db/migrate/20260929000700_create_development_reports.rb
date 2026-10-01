class CreateDevelopmentReports < ActiveRecord::Migration[8.1]
  def change
    create_table :development_reports do |t|
      t.references :project, null: false, foreign_key: { on_delete: :restrict }
      t.references :source_report, foreign_key: { to_table: :development_reports, on_delete: :nullify }
      t.date :reporting_month, null: false
      t.date :report_date, null: false
      t.integer :status, null: false, default: 0
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :submitted_by, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :reviewed_by, foreign_key: { to_table: :users, on_delete: :restrict }
      t.text :review_comment
      t.datetime :submitted_at
      t.datetime :reviewed_at
      t.datetime :approved_at
      t.timestamps
    end

    add_index :development_reports, [ :project_id, :reporting_month, :report_date ], name: "index_reports_on_project_month_date"
    add_index :development_reports, [ :project_id, :status, :report_date ], name: "index_reports_on_project_status_date"
    add_check_constraint :development_reports, "status IN (0, 1, 2, 3)", name: "development_reports_status_check"
    add_check_constraint :development_reports, "EXTRACT(DAY FROM reporting_month) = 1", name: "development_reports_month_first_day"
    add_check_constraint :development_reports,
      "DATE_TRUNC('month', report_date)::date = reporting_month",
      name: "development_reports_report_date_in_month"
  end
end
