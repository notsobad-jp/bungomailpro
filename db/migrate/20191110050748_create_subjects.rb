class CreateSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :subjects, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.integer :books_count, default: 0
      t.timestamps
    end
  end
end
