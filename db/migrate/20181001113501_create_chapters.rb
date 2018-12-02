class CreateChapters < ActiveRecord::Migration[5.2]
  def change
    create_table :chapters do |t|
      t.references :book, foreign_key: true, null: false
      t.integer :index, null: false
      t.text :text
      t.timestamps
    end
    add_index :chapters, :index
    add_index :chapters, [:book_id, :index], unique: true
  end
end
