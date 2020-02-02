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

ActiveRecord::Schema.define(version: 20200131220723) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "cash_flow", default: true
    t.integer "priority", null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_categories", force: :cascade do |t|
    t.string "name"
    t.integer "default_amount", null: false
    t.boolean "monthly", default: true, null: false
    t.boolean "expense", default: true, null: false
    t.boolean "accrual", default: false, null: false
    t.datetime "archived_at"
    t.bigint "icon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["icon_id"], name: "index_budget_categories_on_icon_id"
  end

  create_table "budget_category_maturity_intervals", force: :cascade do |t|
    t.integer "budget_interval_id", null: false
    t.integer "budget_category_id", null: false
    t.index ["budget_category_id", "budget_interval_id"], name: "index_category_interval_uniqueness", unique: true
  end

  create_table "budget_intervals", force: :cascade do |t|
    t.integer "month", null: false
    t.integer "year", null: false
    t.datetime "set_up_completed_at"
    t.datetime "close_out_completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_items", force: :cascade do |t|
    t.integer "month"
    t.integer "year"
    t.integer "amount"
    t.bigint "budget_category_id", null: false
    t.bigint "budget_interval_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_category_id"], name: "index_budget_items_on_budget_category_id"
    t.index ["budget_interval_id"], name: "index_budget_items_on_budget_interval_id"
  end

  create_table "icons", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "class_name", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transaction_details", force: :cascade do |t|
    t.bigint "transaction_entry_id", null: false
    t.bigint "budget_item_id"
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_item_id"], name: "index_transaction_details_on_budget_item_id"
    t.index ["transaction_entry_id"], name: "index_transaction_details_on_transaction_entry_id"
  end

  create_table "transaction_entries", force: :cascade do |t|
    t.string "description", limit: 255
    t.string "check_number", limit: 12
    t.date "clearance_date"
    t.bigint "account_id", null: false
    t.text "notes"
    t.boolean "budget_exclusion", default: false, null: false
    t.bigint "transfer_id"
    t.string "receipt", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transaction_entries_on_account_id"
    t.index ["transfer_id"], name: "index_transaction_entries_on_transfer_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.integer "to_transaction_id", null: false
    t.integer "from_transaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "budget_categories", "icons"
  add_foreign_key "budget_category_maturity_intervals", "budget_categories"
  add_foreign_key "budget_category_maturity_intervals", "budget_intervals"
  add_foreign_key "budget_items", "budget_categories"
  add_foreign_key "budget_items", "budget_intervals"
  add_foreign_key "transaction_details", "budget_items"
  add_foreign_key "transaction_details", "transaction_entries"
  add_foreign_key "transaction_entries", "accounts"
  add_foreign_key "transaction_entries", "transfers"
end
