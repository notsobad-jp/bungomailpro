class CreateChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :channels do |t|
      t.string :token, null: false
      t.references :user, foreign_key: true, null: false
      t.references :next_chapter, foreign_key: { to_table: :chapters }
      t.references :last_chapter, foreign_key: { to_table: :chapters }
      t.string :title, null: false
      t.text :description
      t.integer :deliver_at, default: 8
      t.boolean :public, null: false, default: false
      t.integer :books_count, null: false, default: 0
      t.integer :subscribers_count, null: false, default: 0

      t.timestamps
    end
    add_index :channels, :public
    add_index :channels, :token, unique: true
  end
end
