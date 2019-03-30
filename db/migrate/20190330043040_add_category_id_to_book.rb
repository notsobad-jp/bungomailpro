class AddCategoryIdToBook < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :category_id, :string
    add_foreign_key :books, :categories
  end
end
