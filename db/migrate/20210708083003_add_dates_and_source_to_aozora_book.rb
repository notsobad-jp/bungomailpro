class AddDatesAndSourceToAozoraBook < ActiveRecord::Migration[6.0]
  def change
    add_column :aozora_books, :published_date, :date
    add_column :aozora_books, :last_updated_date, :date
    add_column :aozora_books, :source, :string
  end
end
