class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.integer :aozora_id, null: false
      t.string :title
      t.string :author
    end
    add_index :books, :aozora_id, unique: true
  end
end
