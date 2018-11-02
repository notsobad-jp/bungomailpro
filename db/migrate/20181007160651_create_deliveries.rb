class CreateDeliveries < ActiveRecord::Migration[5.2]
  def change
    create_table :deliveries do |t|
      t.references :user_course, foreign_key: true
      t.references :book, foreign_key: true
      t.integer :index, null: false
      t.text :text
      t.datetime :deliver_at
      t.boolean :delivered, default: false

      t.timestamps
    end
    add_index :deliveries, :deliver_at
    add_index :deliveries, :delivered
    add_index :deliveries, [:user_course_id, :book_id, :index], unique: true
  end
end
