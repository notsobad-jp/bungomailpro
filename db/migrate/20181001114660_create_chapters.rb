class CreateChapters < ActiveRecord::Migration[5.2]
  def change
    create_table :chapters do |t|
      t.references :book, foreign_key: true
      t.integer :index, null: false
      t.text :text

      t.timestamps
    end
    add_index :chapters, :index
  end
end
