class AddDeliverySettingsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :timezone, :string, default: 'UTC'
    add_column :users, :delivery_time, :string, default: '07:00'
    add_column :users, :words_per_day, :integer, default: 400
  end
end
