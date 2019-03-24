class AddAccessToBook < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :access_count, :integer, default: 0
    add_index :books, :access_count

    change_column :books, :words_count, :integer, default: 0
    add_index :books, :words_count
  end
end
