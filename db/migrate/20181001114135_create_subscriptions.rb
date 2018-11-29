class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true, null: false
      t.references :book, foreign_key: true, null: false
      t.references :list, foreign_key: true
      t.integer :index, null: false, default: 1
      t.integer :status, null: false, default: 1, comment: '1:waiting, 2:delivering, 3:finished'

      t.timestamps
    end
    add_index :subscriptions, :status
    add_index :subscriptions, :index
    add_index :subscriptions, [:user_id, :book_id], unique: true
    add_index :subscriptions, [:user_id, :index], unique: true
  end
end
