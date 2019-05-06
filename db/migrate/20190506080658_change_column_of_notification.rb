class ChangeColumnOfNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :title, :string, null: true
    remove_column :notifications, :date, :date
  end
end
