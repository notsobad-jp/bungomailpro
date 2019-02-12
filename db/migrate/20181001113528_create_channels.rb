class CreateChannels < ActiveRecord::Migration[5.2]
  def up
    create_table :channels, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: 'private', comment: 'IN (private public streaming)'
      t.boolean :default, null: false, default: false
      t.integer :books_count, null: false, default: 0
      t.integer :subscribers_count, null: false, default: 0

      t.timestamps
    end
    add_index :channels, :status
    add_index :channels, [:user_id, :default], where: '"default" = true', unique: true

    # statusの許可リスト
    execute "ALTER TABLE channels ADD CONSTRAINT restrict_status_values CHECK (status IN ('private', 'public', 'streaming'));"
    # privateじゃないとき（public, streaming）は、descriptionも入力必須
    execute "ALTER TABLE channels ADD CONSTRAINT require_description_when_public CHECK (status = 'private' OR (description IS NOT NULL AND description <> ''));"
  end

  def down
    drop_table :channels
  end
end
