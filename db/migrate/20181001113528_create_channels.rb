class CreateChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :channels do |t|
      t.references :user, foreign_key: true, null: false
      t.references :book, foreign_key: true
      t.integer :index
      t.string :title, null: false
      t.text :description
      t.boolean :public, null: false, default: false
      t.integer :books_count, null: false, default: 0
      t.integer :subscribers_count, null: false, default: 0

      t.timestamps
    end
    add_index :channels, :public
  end
end
