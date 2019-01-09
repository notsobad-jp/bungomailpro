class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books, id: false do |t|
      t.integer :id, limit: 8, null: false
      t.string :title, null: false
      t.string :author, null: false
      t.integer :author_id, limit: 8, null: false
      t.integer :file_id, limit: 8
      t.text :footnote
      t.integer :chapters_count, null: false, default: 0
      t.timestamps
    end
    execute "ALTER TABLE books ADD PRIMARY KEY (id);"
  end
end
