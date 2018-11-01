class CreateCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description
      t.integer :owner_id, limit: 8, null: false
      t.integer :status, null: false, default: 1, comment: '1:draft, 2:public, 3:closed'

      t.timestamps
    end
    add_index :courses, :owner_id
  end
end
