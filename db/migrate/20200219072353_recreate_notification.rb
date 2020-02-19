class RecreateNotification < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications, id: :uuid do |t|
      t.string :title
      t.text :content
      t.datetime :send_at
      t.timestamps
    end
    change_column_default :notifications, :created_at, from: nil, to: -> { 'now()' }
    change_column_default :notifications, :updated_at, from: nil, to: -> { 'now()' }
  end
end
