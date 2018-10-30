class CreateUserCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :user_courses do |t|
      t.references :user, foreign_key: true
      t.references :course, foreign_key: true
      t.integer :status, null: false, default: 1, comment: '1:active, 2:paused, 3:finished'
      t.text :delivery_hours

      t.timestamps
    end
    add_index :user_courses, :status
    add_index  :user_courses, [:user_id, :course_id], unique: true
  end
end
