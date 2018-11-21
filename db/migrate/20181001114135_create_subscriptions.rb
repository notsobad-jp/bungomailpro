class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true
      t.references :course, foreign_key: true
      t.integer :next_book_index, null: false, default: 1
      t.integer :status, null: false, default: 1, comment: '1:active, 2:paused, 3:finished'
      t.text :delivery_hours

      t.timestamps
    end
    add_index :subscriptions, :status
    add_index :subscriptions, [:user_id, :course_id], unique: true
  end
end
