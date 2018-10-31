class CreateCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description
      t.integer :owner_id, limit: 8, null: false

      t.timestamps
    end
    add_index :courses, :owner_id
  end
end
