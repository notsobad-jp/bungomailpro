class AddCategoryIdToGutenBook < ActiveRecord::Migration[6.0]
  def change
    add_column :guten_books, :category_id, :string
    add_index :guten_books, :category_id
  end
end
