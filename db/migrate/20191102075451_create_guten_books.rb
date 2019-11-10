class CreateGutenBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :guten_books, id: false do |t|
      t.integer :id, limit: 8, null: false, primary_key: true
      t.string :title, null: false
      t.string :author, null: false
      t.string :rights
      t.string :language
      t.integer :downloads, limit: 8
      t.integer :words_count, null: false, default: 0
      t.timestamps
    end
  end
end
