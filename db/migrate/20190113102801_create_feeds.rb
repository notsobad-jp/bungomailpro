class CreateFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :feeds, id: false do |t|
      t.references :subscription, foreign_key: true, null: false, index: false, primary_key: true
      t.json :entries

      t.timestamps
    end
  end
end
