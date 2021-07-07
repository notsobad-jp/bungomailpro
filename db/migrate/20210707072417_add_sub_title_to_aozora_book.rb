class AddSubTitleToAozoraBook < ActiveRecord::Migration[6.0]
  def change
    add_column :aozora_books, :sub_title, :string
  end
end
