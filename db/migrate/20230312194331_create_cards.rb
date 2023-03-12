class CreateCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|
      t.string :number, limit: 16
      t.integer :expiration_month, limit: 2
      t.integer :expiration_year, limit: 4
      t.integer :cvv, limit: 3
      t.integer :pin, limit: 4
      t.decimal :balance
      t.integer :kind
      t.integer :status
      t.boolean :default
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
