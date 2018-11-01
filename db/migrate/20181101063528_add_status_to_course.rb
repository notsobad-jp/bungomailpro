class AddStatusToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :status, :integer, null: false, default: 1
    add_index :courses, :status
  end
end
