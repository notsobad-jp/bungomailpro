class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :name, null: false
      t.integer :range_from
      t.integer :range_to
    end
    add_index :categories, :range_from
  end
end
