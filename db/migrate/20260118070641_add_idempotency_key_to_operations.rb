class AddIdempotencyKeyToOperations < ActiveRecord::Migration[7.0]
  def change
    add_column :operations, :idempotency_key, :string
    add_index :operations, :idempotency_key
  end
end
