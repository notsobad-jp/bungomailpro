class CreateListBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :list_books do |t|
      t.references :list, foreign_key: true
      t.references :book, foreign_key: true
      t.integer :index, null: false
      t.text :comment

      t.timestamps
    end
    add_index :list_books, :index
    add_index :list_books, [:list_id, :book_id], unique: true
    add_index :list_books, [:list_id, :index], unique: true
  end
end
