class CreateDeliveries < ActiveRecord::Migration[5.2]
  def change
    create_table :deliveries do |t|
      t.references :user_book, index: { unique: true }, foreign_key: true, null: false
      t.integer :next_index, null: false, default: 1
      t.datetime :deliver_at

      t.timestamps
    end
    add_index :deliveries, :deliver_at
  end
end
