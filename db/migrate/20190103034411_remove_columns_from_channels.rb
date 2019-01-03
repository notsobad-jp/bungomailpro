class RemoveColumnsFromChannels < ActiveRecord::Migration[5.2]
  def change
    remove_column :channel_books, :delivered, :boolean, default: false, null: false
    remove_column :channels, :deliver_at, :integer, default: 8
    remove_reference :channels, :next_chapter, foreign_key: { to_table: :chapters }
    remove_reference :channels, :last_chapter, foreign_key: { to_table: :chapters }
    add_column :channels, :default, :boolean, default: false, null: false
    add_index :channels, [:user_id, :default], where: '"default" = true', unique: true
  end
end
