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

ActiveRecord::Schema[7.0].define(version: 2023_03_12_194331) do
  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "clabe", limit: 18
    t.string "phone", limit: 10
    t.string "email"
    t.decimal "balance"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cards", force: :cascade do |t|
    t.string "number", limit: 16
    t.integer "expiration_month", limit: 2
    t.integer "expiration_year", limit: 4
    t.integer "cvv", limit: 3
    t.integer "pin", limit: 4
    t.decimal "balance"
    t.integer "kind"
    t.integer "status"
    t.boolean "default"
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_cards_on_account_id"
  end

  add_foreign_key "cards", "accounts"
end
