class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.string :token, null: false
      t.references :user, foreign_key: true, null: false
      t.references :channel, foreign_key: true, null: false
      t.references :current_book, foreign_key: { to_table: :books }
      t.integer :next_chapter_index
      t.integer :delivery_hour, default: 8, null: false
      t.date :mext_delivery_date

      t.timestamps
    end
    add_index :subscriptions, :token, unique: true
    add_index :subscriptions, [:user_id, :channel_id], unique: true
  end
end
