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

ActiveRecord::Schema[8.0].define(version: 2026_07_31_080000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "credit_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "shop_id", null: false
    t.uuid "customer_id", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.decimal "amount_paid", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "balance", precision: 10, scale: 2, null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_credit_entries_on_customer_id"
    t.index ["shop_id"], name: "index_credit_entries_on_shop_id"
  end

  create_table "credit_entry_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "credit_entry_id", null: false
    t.uuid "inventory_item_id"
    t.string "name", null: false
    t.decimal "qty", precision: 10, scale: 2, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "total", precision: 10, scale: 2, null: false
    t.string "category"
    t.decimal "amount_paid", precision: 10, scale: 2, default: "0.0"
    t.decimal "balance", precision: 10, scale: 2, default: "0.0"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credit_entry_id"], name: "index_credit_entry_items_on_credit_entry_id"
    t.index ["inventory_item_id"], name: "index_credit_entry_items_on_inventory_item_id"
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "shop_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_customers_on_shop_id"
  end

  create_table "inventory_fraction_prices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "inventory_item_id", null: false
    t.string "label", null: false
    t.decimal "fraction", precision: 10, scale: 4, null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_item_id"], name: "index_inventory_fraction_prices_on_inventory_item_id"
  end

  create_table "inventory_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "shop_id", null: false
    t.string "name", null: false
    t.decimal "current_stock", precision: 10, scale: 2, default: "0.0", null: false
    t.string "buying_unit", null: false
    t.string "selling_unit", null: false
    t.decimal "conversion_rate", precision: 10, scale: 4, null: false
    t.decimal "low_stock_threshold", precision: 10, scale: 2, default: "0.0", null: false
    t.string "category", null: false
    t.text "description"
    t.string "icon"
    t.decimal "buying_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_inventory_items_on_shop_id"
  end

  create_table "sale_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sale_id", null: false
    t.uuid "inventory_item_id"
    t.string "name", null: false
    t.decimal "qty", precision: 10, scale: 2, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.string "item_type", null: false
    t.string "icon"
    t.boolean "is_service", default: false, null: false
    t.string "unit_type"
    t.string "fraction_label"
    t.string "unit_label"
    t.string "variant_label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_item_id"], name: "index_sale_items_on_inventory_item_id"
    t.index ["sale_id"], name: "index_sale_items_on_sale_id"
  end

  create_table "sales", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "shop_id", null: false
    t.decimal "total", precision: 10, scale: 2, null: false
    t.string "payment_method", null: false
    t.datetime "completed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_sales_on_shop_id"
  end

  create_table "shops", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "location"
    t.string "shop_type", default: "cereal", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "credit_entries", "customers"
  add_foreign_key "credit_entries", "shops"
  add_foreign_key "credit_entry_items", "credit_entries"
  add_foreign_key "credit_entry_items", "inventory_items"
  add_foreign_key "customers", "shops"
  add_foreign_key "inventory_fraction_prices", "inventory_items"
  add_foreign_key "inventory_items", "shops"
  add_foreign_key "sale_items", "inventory_items"
  add_foreign_key "sale_items", "sales"
  add_foreign_key "sales", "shops"
end
