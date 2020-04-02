class AddPublishedAtAndCharTypeToAozoraBook < ActiveRecord::Migration[6.0]
  def change
    add_column :aozora_books, :first_edition, :string
    add_column :aozora_books, :published_at, :integer
    add_column :aozora_books, :character_type, :string
    add_index :aozora_books, :published_at
    add_index :aozora_books, :character_type
  end
end
