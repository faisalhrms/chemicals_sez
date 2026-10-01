# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_29_001100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "auditable_type", null: false
    t.bigint "auditable_id", null: false
    t.string "action", limit: 100, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.index ["action"], name: "index_audit_events_on_action"
    t.index ["auditable_type", "auditable_id", "created_at"], name: "index_audit_events_on_auditable_and_created_at"
    t.index ["user_id"], name: "index_audit_events_on_user_id"
  end

  create_table "committee_meetings", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "committee_name", limit: 200, null: false
    t.date "meeting_on", null: false
    t.bigint "created_by_id", null: false
    t.bigint "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_committee_meetings_on_created_by_id"
    t.index ["project_id", "meeting_on"], name: "index_committee_meetings_on_project_id_and_meeting_on"
    t.index ["project_id"], name: "index_committee_meetings_on_project_id"
    t.index ["updated_by_id"], name: "index_committee_meetings_on_updated_by_id"
  end

  create_table "development_categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_development_categories_on_lower_name", unique: true
    t.index ["position"], name: "index_development_categories_on_position", unique: true
    t.check_constraint "\"position\" > 0", name: "development_categories_position_positive"
  end

  create_table "development_report_items", force: :cascade do |t|
    t.bigint "development_report_id", null: false
    t.bigint "development_category_id", null: false
    t.decimal "completion_percentage", precision: 5, scale: 2
    t.date "expected_completion_on"
    t.text "delay_reason"
    t.text "support_required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["development_report_id", "development_category_id"], name: "index_report_items_on_report_and_category", unique: true
    t.check_constraint "completion_percentage IS NULL OR completion_percentage >= 0::numeric AND completion_percentage <= 100::numeric", name: "development_report_items_completion_range"
  end

  create_table "development_reports", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "source_report_id"
    t.date "reporting_month", null: false
    t.date "report_date", null: false
    t.integer "status", default: 0, null: false
    t.bigint "created_by_id", null: false
    t.bigint "submitted_by_id"
    t.bigint "reviewed_by_id"
    t.text "review_comment"
    t.datetime "submitted_at"
    t.datetime "reviewed_at"
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_development_reports_on_created_by_id"
    t.index ["project_id", "reporting_month", "report_date"], name: "index_reports_on_project_month_date"
    t.index ["project_id", "status", "report_date"], name: "index_reports_on_project_status_date"
    t.index ["project_id"], name: "index_development_reports_on_project_id"
    t.index ["reviewed_by_id"], name: "index_development_reports_on_reviewed_by_id"
    t.index ["source_report_id"], name: "index_development_reports_on_source_report_id"
    t.index ["submitted_by_id"], name: "index_development_reports_on_submitted_by_id"
    t.check_constraint "date_part('day'::text, reporting_month) = 1::double precision", name: "development_reports_month_first_day"
    t.check_constraint "date_trunc('month'::text, report_date::timestamp with time zone)::date = reporting_month", name: "development_reports_report_date_in_month"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2, 3])", name: "development_reports_status_check"
  end

  create_table "nocs", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "description", limit: 250, null: false
    t.date "applied_on", null: false
    t.date "attained_on"
    t.bigint "created_by_id", null: false
    t.bigint "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_nocs_on_created_by_id"
    t.index ["project_id", "applied_on"], name: "index_nocs_on_project_id_and_applied_on"
    t.index ["project_id"], name: "index_nocs_on_project_id"
    t.index ["updated_by_id"], name: "index_nocs_on_updated_by_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "zone_name", null: false
    t.string "zone_developer", null: false
    t.string "zone_type"
    t.string "ownership_type"
    t.date "notification_on"
    t.string "total_zone_area"
    t.string "zone_location"
    t.string "zone_status"
    t.string "regulatory_framework"
    t.string "company_name"
    t.integer "company_incorporated_year"
    t.string "project_name", null: false
    t.string "project_capacity"
    t.string "project_location"
    t.string "project_cost"
    t.string "process_technology"
    t.text "products"
    t.text "raw_materials"
    t.string "export_potential"
    t.text "market_positioning"
    t.string "employment_generation"
    t.date "notice_to_proceed_on"
    t.date "engineering_start_on"
    t.date "engineering_end_on"
    t.date "procurement_start_on"
    t.date "procurement_end_on"
    t.date "construction_start_on"
    t.date "construction_end_on"
    t.date "mechanical_completion_on"
    t.date "commissioning_start_on"
    t.date "commissioning_end_on"
    t.date "commercial_operations_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address", limit: 64
    t.string "user_agent", limit: 500
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_sessions_on_created_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", limit: 120, null: false
    t.string "email_address", limit: 255, null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone", limit: 40
    t.string "job_title", limit: 120
    t.integer "portal_layout", default: 0, null: false
    t.integer "theme_preference", default: 1, null: false
    t.integer "table_density", default: 0, null: false
    t.index "lower((email_address)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.check_constraint "portal_layout = ANY (ARRAY[0, 1])", name: "users_portal_layout_check"
    t.check_constraint "role = ANY (ARRAY[0, 1, 2])", name: "users_role_check"
    t.check_constraint "table_density = ANY (ARRAY[0, 1])", name: "users_table_density_check"
    t.check_constraint "theme_preference = ANY (ARRAY[0, 1, 2])", name: "users_theme_preference_check"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id", on_delete: :cascade
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id", on_delete: :cascade
  add_foreign_key "audit_events", "users", on_delete: :restrict
  add_foreign_key "committee_meetings", "projects", on_delete: :restrict
  add_foreign_key "committee_meetings", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "committee_meetings", "users", column: "updated_by_id", on_delete: :restrict
  add_foreign_key "development_report_items", "development_categories", on_delete: :restrict
  add_foreign_key "development_report_items", "development_reports", on_delete: :cascade
  add_foreign_key "development_reports", "development_reports", column: "source_report_id", on_delete: :nullify
  add_foreign_key "development_reports", "projects", on_delete: :restrict
  add_foreign_key "development_reports", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "development_reports", "users", column: "reviewed_by_id", on_delete: :restrict
  add_foreign_key "development_reports", "users", column: "submitted_by_id", on_delete: :restrict
  add_foreign_key "nocs", "projects", on_delete: :restrict
  add_foreign_key "nocs", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "nocs", "users", column: "updated_by_id", on_delete: :restrict
  add_foreign_key "sessions", "users", on_delete: :cascade
end
