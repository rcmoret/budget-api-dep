# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180726043121) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.boolean "cash_flow", default: true
    t.boolean "health_savings_account", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "priority"
  end

  create_table "budget_items", force: :cascade do |t|
    t.string "name"
    t.decimal "default_amount", null: false
    t.boolean "monthly", default: true
    t.boolean "expense", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.string "icon"
  end

  create_table "monthly_amounts", force: :cascade do |t|
    t.string "month"
    t.decimal "amount"
    t.integer "budget_item_id"
    t.index ["budget_item_id"], name: "index_monthly_amounts_on_budget_item_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "description"
    t.decimal "amount"
    t.date "clearance_date"
    t.integer "check_number"
    t.integer "account_id"
    t.integer "monthly_amount_id"
    t.integer "primary_transaction_id"
    t.text "notes"
    t.string "receipt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "budget_exclusion", default: false
    t.integer "transfer_id"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["monthly_amount_id"], name: "index_transactions_on_monthly_amount_id"
    t.index ["primary_transaction_id"], name: "index_transactions_on_primary_transaction_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.integer "to_transaction_id", null: false
    t.integer "from_transaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "user_name", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "monthly_amounts", "budget_items"
  add_foreign_key "transactions", "accounts"
end
