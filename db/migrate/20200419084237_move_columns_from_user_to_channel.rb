class MoveColumnsFromUserToChannel < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :delivery_time, :string, default: '07:00', null: false
    remove_column :users, :words_per_day, :integer, default: 400, null: false
    add_column :users, :locale, :string, default: "ja", null: false

    add_column :channels, :delivery_time, :time, default: '07:00', null: false
    add_column :channels, :words_per_day, :integer, default: 400, null: false
    add_column :channels, :chars_per_day, :integer, default: 750, null: false
  end
end
