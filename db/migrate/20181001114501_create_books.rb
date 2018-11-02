class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books, id: false do |t|
      t.integer :id, limit: 8, null: false
      t.string :title, null: false
      t.string :author, null: false
      t.integer :author_id, limit: 8, null: false
      t.text :text
      t.text :footnote
    end
    add_index :books, :id, unique: true
  end
end
