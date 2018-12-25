class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.references :channel, foreign_key: true, null: false
      t.text :text
      t.date :date

      t.timestamps
    end
    add_index :comments, :date
  end
end
