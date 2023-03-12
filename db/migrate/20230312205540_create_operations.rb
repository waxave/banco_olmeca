class CreateOperations < ActiveRecord::Migration[7.0]
  def change
    create_table :operations do |t|
      t.references :account, null: false, foreign_key: true
      t.string :concept
      t.decimal :amount
      t.integer :kind
      t.references :operationable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
