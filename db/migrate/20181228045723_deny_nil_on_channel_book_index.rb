class DenyNilOnChannelBookIndex < ActiveRecord::Migration[5.2]
  def up
    change_column :channel_books, :index, :integer, null: false
  end
  def down
    change_column :channel_books, :index, :integer, null: true
  end
end
