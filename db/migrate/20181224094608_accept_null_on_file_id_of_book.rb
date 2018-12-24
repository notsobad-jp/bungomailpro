class AcceptNullOnFileIdOfBook < ActiveRecord::Migration[5.2]
  def up
    change_column :books, :file_id, :integer, limit: 8, null: true
  end
  def down
    change_column :books, :file_id, :integer, limit: 8, null: false
  end
end
