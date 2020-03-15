class AddIndexToBooksCategoryId < ActiveRecord::Migration[6.0]
  def change
    add_index :books, :category_id
  end
end
