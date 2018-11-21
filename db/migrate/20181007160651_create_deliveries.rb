class CreateDeliveries < ActiveRecord::Migration[5.2]
  def change
    create_table :deliveries do |t|
      t.references :subscription, foreign_key: true
      t.references :book, foreign_key: true
      t.integer :index, null: false
      t.text :text
      t.datetime :deliver_at
      t.boolean :delivered, default: false

      t.timestamps
    end
    add_index :deliveries, :deliver_at
    add_index :deliveries, :delivered
    add_index :deliveries, [:subscription_id, :book_id, :index], unique: true
  end
end
