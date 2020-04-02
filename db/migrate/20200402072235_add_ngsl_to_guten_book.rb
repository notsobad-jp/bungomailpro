class AddNgslToGutenBook < ActiveRecord::Migration[6.0]
  def change
    add_column :guten_books, :unique_words_count, :integer, default: 0
    add_column :guten_books, :ngsl_words_count, :integer, default: 0
    add_column :guten_books, :ngsl_ratio, :float
    add_column :guten_books, :birth_year, :integer
    add_column :guten_books, :death_year, :integer
    add_index :guten_books, :ngsl_ratio
  end
end
