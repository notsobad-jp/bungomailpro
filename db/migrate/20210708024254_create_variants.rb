class CreateVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :book_variants, id: :uuid do |t|
      t.integer :standard_book_id, null: false
      t.integer :variant_book_id, null: false
      t.string :character_type, null: false
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end
    add_index :book_variants, :standard_book_id
    add_index :book_variants, :variant_book_id
    add_index :book_variants, [:standard_book_id, :variant_book_id], unique: true
  end
end
