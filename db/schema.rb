# frozen_string_literal: true

# Add rubocop exception for schema.rb block length
# rubocop:disable Metrics/BlockLength

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

ActiveRecord::Schema[7.0].define(version: 20_260_118_070_641) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'accounts', force: :cascade do |t|
    t.string 'name'
    t.string 'clabe', limit: 18
    t.string 'phone', limit: 10
    t.string 'email'
    t.decimal 'balance'
    t.string 'password_digest'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['email'], name: 'index_accounts_on_email', unique: true
    t.index ['phone'], name: 'index_accounts_on_phone', unique: true
  end

  create_table 'cards', force: :cascade do |t|
    t.string 'number', limit: 16
    t.integer 'expiration_month', limit: 2
    t.integer 'expiration_year'
    t.integer 'cvv'
    t.integer 'pin'
    t.decimal 'balance'
    t.integer 'kind'
    t.integer 'status'
    t.boolean 'default'
    t.bigint 'account_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['account_id'], name: 'index_cards_on_account_id'
  end

  create_table 'contacts', force: :cascade do |t|
    t.bigint 'account_id', null: false
    t.string 'name'
    t.string 'contactable_type', null: false
    t.bigint 'contactable_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['account_id'], name: 'index_contacts_on_account_id'
    t.index %w[contactable_type contactable_id], name: 'index_contacts_on_contactable'
  end

  create_table 'operations', force: :cascade do |t|
    t.bigint 'account_id', null: false
    t.string 'concept'
    t.decimal 'amount'
    t.integer 'kind'
    t.string 'operationable_type', null: false
    t.bigint 'operationable_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'idempotency_key'
    t.index ['account_id'], name: 'index_operations_on_account_id'
    t.index %w[operationable_type operationable_id], name: 'index_operations_on_operationable'
    t.index ['idempotency_key'], name: 'index_operations_on_idempotency_key', unique: true
  end

  add_foreign_key 'cards', 'accounts'
  add_foreign_key 'contacts', 'accounts'
  add_foreign_key 'operations', 'accounts'
end
