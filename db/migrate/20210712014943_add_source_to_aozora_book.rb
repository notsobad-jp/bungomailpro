class AddSourceToAozoraBook < ActiveRecord::Migration[6.0]
  def change
    add_column :aozora_books, :source, :string
  end
end
