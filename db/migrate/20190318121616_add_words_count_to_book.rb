class AddWordsCountToBook < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :words_count, :integer
  end
end
