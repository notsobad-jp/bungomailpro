class RemoveNotNullFromBookAuthorId < ActiveRecord::Migration[5.2]
  def change
    change_column :books, :author_id,:integer, limit: 8, null: true
    add_column :books, :group, :string, null: true
    add_index :books, :group
  end
end
