class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name
      t.references :contactable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
