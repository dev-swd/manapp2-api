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

ActiveRecord::Schema.define(version: 2023_02_05_130057) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applicationroles", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "applications", force: :cascade do |t|
    t.bigint "applicationrole_id"
    t.bigint "applicationtemp_id"
    t.boolean "permission", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["applicationrole_id"], name: "index_applications_on_applicationrole_id"
    t.index ["applicationtemp_id"], name: "index_applications_on_applicationtemp_id"
  end

  create_table "applicationtemps", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.integer "sort_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "approvalauths", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "division_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["division_id"], name: "index_approvalauths_on_division_id"
    t.index ["user_id"], name: "index_approvalauths_on_user_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "divisions", force: :cascade do |t|
    t.bigint "department_id"
    t.string "code"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id"], name: "index_divisions_on_department_id"
  end

  create_table "leadlogs", force: :cascade do |t|
    t.bigint "prospect_id"
    t.bigint "lead_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["prospect_id"], name: "index_leadlogs_on_prospect_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "name"
    t.string "period_kbn"
    t.integer "period"
    t.integer "sort_key"
    t.integer "color_r"
    t.integer "color_g"
    t.integer "color_b"
    t.decimal "color_a", precision: 3, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.integer "sort_key"
    t.integer "color_r"
    t.integer "color_g"
    t.integer "color_b"
    t.decimal "color_a", precision: 3, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "prospects", force: :cascade do |t|
    t.string "name"
    t.bigint "division_id"
    t.bigint "make_id"
    t.bigint "update_id"
    t.string "company_name"
    t.string "department_name"
    t.string "person_in_charge_name"
    t.string "phone"
    t.string "fax"
    t.string "email"
    t.bigint "product_id"
    t.bigint "lead_id"
    t.text "content"
    t.date "period_fr"
    t.date "period_to"
    t.bigint "main_person_id"
    t.bigint "order_amount"
    t.string "sales_channels"
    t.string "sales_person"
    t.date "closing_date"
    t.date "lost_date"
    t.date "delete_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "salesactions", force: :cascade do |t|
    t.string "name"
    t.integer "sort_key"
    t.integer "color_r"
    t.integer "color_g"
    t.integer "color_b"
    t.decimal "color_a", precision: 3, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "salesreports", force: :cascade do |t|
    t.bigint "prospect_id"
    t.date "report_date"
    t.bigint "make_id"
    t.bigint "update_id"
    t.bigint "salesaction_id"
    t.string "topics"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["prospect_id"], name: "index_salesreports_on_prospect_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "employee_number"
    t.string "name_kana"
    t.date "birthday"
    t.string "address"
    t.string "phone"
    t.date "joining_date"
    t.bigint "division_id"
    t.bigint "authority_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "applications", "applicationroles"
  add_foreign_key "applications", "applicationtemps"
  add_foreign_key "approvalauths", "divisions"
  add_foreign_key "approvalauths", "users"
  add_foreign_key "divisions", "departments"
  add_foreign_key "leadlogs", "prospects"
  add_foreign_key "salesreports", "prospects"
end
