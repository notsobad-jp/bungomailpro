class CreateLists < ActiveRecord::Migration[5.2]
  def change
    create_table :lists do |t|
      t.references :user, foreign_key: true, null: false
      t.string :title, null: false
      t.text :description
      t.boolean :published, null: false, default: false

      t.timestamps
    end
    add_index :lists, :published
  end
end
