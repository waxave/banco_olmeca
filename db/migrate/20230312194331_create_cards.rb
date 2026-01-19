class CreateCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|
      add_card_fields(t)
      add_account_reference(t)
      add_timestamps(t)
    end
  end

  private

  def add_card_fields(table)
    table.string :number, limit: 16
    table.integer :expiration_month, limit: 2
    table.integer :expiration_year, limit: 4
    table.integer :cvv, limit: 3
    table.integer :pin, limit: 4
    table.decimal :balance
    table.integer :kind
    table.integer :status
    table.boolean :default
  end

  def add_account_reference(table)
    table.references :account, null: false, foreign_key: true
  end

  def add_timestamps(table)
    table.timestamps
  end
end
