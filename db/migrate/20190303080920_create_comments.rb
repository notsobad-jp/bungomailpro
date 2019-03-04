class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments, id: :uuid do |t|
      t.references :subscription, type: :uuid, foreign_key: true, null: false
      t.references :book, foreign_key: true, null: false
      t.integer :index, null: false
      t.text :text

      t.timestamps
    end
    add_index :comments, [:subscription_id, :book_id, :index], unique: true
  end
end
