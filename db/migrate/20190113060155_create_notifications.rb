class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.date :date, null: false
      t.text :text

      t.timestamps
    end
    add_index :notifications, :date, unique: true
  end
end
