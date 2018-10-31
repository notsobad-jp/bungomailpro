class UpdateColumnCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :owner_id, :integer, null: false, default: 1
    add_index :courses, :owner_id
  end
end
