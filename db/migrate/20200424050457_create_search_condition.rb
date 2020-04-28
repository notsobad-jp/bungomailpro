class CreateSearchCondition < ActiveRecord::Migration[6.0]
  def change
    create_table :search_conditions, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.jsonb :query, default: {}, null: false
      t.string :book_type, null: false
      t.integer :book_ids, array: true
      t.timestamps
    end
  end
end
