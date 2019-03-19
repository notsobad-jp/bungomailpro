class AddWordsCountAndBeginningToBook < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :words_count, :integer
    add_column :books, :beginning, :string
  end
end
