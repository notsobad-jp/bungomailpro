class AddBeginningToGutenBook < ActiveRecord::Migration[6.0]
  def change
    add_column :guten_books, :beginning, :string
  end
end
