class CreateFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :feeds do |t|
      t.references :subscription, type: :uuid, foreign_key: true, null: false
      t.references :book, foreign_key: true, null: false
      t.integer :index, null: false
      t.datetime :delivered_at, null: false

      t.timestamps
    end
    add_index :feeds, :delivered_at
  end
end
