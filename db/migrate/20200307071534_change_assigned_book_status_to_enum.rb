class ChangeAssignedBookStatusToEnum < ActiveRecord::Migration[5.2]
  def up
    execute 'ALTER TABLE assigned_books ALTER COLUMN status DROP DEFAULT;'
    # change_column :assigned_books, :status, 'integer USING CAST(status AS integer)', default: 0, null: false
  end

  def down
    # change_column :assigned_books, :status, :string
  end
end
