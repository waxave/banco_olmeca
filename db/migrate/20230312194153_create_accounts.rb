class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :clabe, limit: 18
      t.string :phone, limit: 10
      t.string :email
      t.decimal :balance
      t.string :password_digest

      t.timestamps
    end
  end
end
