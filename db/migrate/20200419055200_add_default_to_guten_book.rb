class AddDefaultToGutenBook < ActiveRecord::Migration[6.0]
  def up
    change_column_default :guten_books, :language, 'en'
    change_column_default :guten_books, :downloads, 0
  end

  def down
    change_column_default :guten_books, :language, nil
    change_column_default :guten_books, :downloads, nil
  end
end
