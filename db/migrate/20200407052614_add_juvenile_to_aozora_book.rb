class AddJuvenileToAozoraBook < ActiveRecord::Migration[6.0]
  def change
    add_column :aozora_books, :juvenile, :boolean, default: false, null: false
    add_index :aozora_books, :juvenile
  end
end
