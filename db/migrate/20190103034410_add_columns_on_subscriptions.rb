class AddColumnsOnSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_reference :subscriptions, :current_book, foreign_key: { to_table: :books }
    add_column :subscriptions, :next_chapter_index, :integer
    add_column :subscriptions, :delivery_hour, :integer, default: 8, null: false
    add_column :subscriptions, :next_delivery_date, :date

    add_column :channels, :default, :boolean, default: false, null: false
    add_index :channels, [:user_id, :default], where: '"default" = true', unique: true

    #TODO: CHECK制約 on delivery_hour
  end
end
