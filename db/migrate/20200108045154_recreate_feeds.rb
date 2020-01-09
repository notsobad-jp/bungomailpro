class RecreateFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :feeds do |t|
      t.references :guten_book, foreign_key: true, null: false
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.integer :index, default: 1, null: false
      t.string :title
      t.text :content
      t.date :send_at
      t.boolean :scheduled, default: false

      t.timestamps
    end
    add_index :feeds, [:guten_book_id, :user_id, :index], unique: true
  end
end
