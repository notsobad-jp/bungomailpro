class CreateChannels < ActiveRecord::Migration[5.2]
  def up
    create_table :channels do |t|
      t.string :token, null: false
      t.references :user, foreign_key: true, null: false
      t.string :title, null: false
      t.text :description
      t.boolean :public, null: false, default: false
      t.boolean :default, null: false, default: false
      t.integer :books_count, null: false, default: 0
      t.integer :subscribers_count, null: false, default: 0

      t.timestamps
    end
    add_index :channels, :public
    add_index :channels, :token, unique: true
    add_index :channels, [:user_id, :default], where: '"default" = true', unique: true

    # publicのときは、descriptionも入力必須
    execute "ALTER TABLE channels ADD CONSTRAINT require_description_when_public CHECK (public IS FALSE OR (description IS NOT NULL AND description <> ''));"
  end

  def down
    drop_table :channels
  end
end
