class CreateAssignedBooks < ActiveRecord::Migration[5.2]
  def up
    create_table :assigned_books do |t|
      t.references :guten_book, foreign_key: true, null: false
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.string :status, comment: 'IN (active finished skipped canceled)', default: 'active'

      t.timestamps
    end
    add_index :assigned_books, :status
    # statusの許可リスト
    execute "ALTER TABLE assigned_books ADD CONSTRAINT restrict_status_values CHECK (status IN ('active', 'finished', 'skipped', 'canceled'));"
  end

  def down
    drop_table :assigned_books
  end
end
