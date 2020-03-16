class AddAuthorIdToGutenBook < ActiveRecord::Migration[6.0]
  def up
    add_column :guten_books, :author_id, :integer
    add_index :guten_books, :author_id
    change_column :guten_books, :author, :string, null: true
    change_column :guten_books, :rights, 'boolean USING CAST(rights AS boolean)'
    change_column :guten_books, :rights, :boolean, default: false
    rename_column :guten_books, :rights, :rights_reserved
  end

  def down
    remove_column :guten_books, :author_id, :integer
    change_column :guten_books, :author, :string, null: false
    rename_column :guten_books, :rights_reserved, :rights
    change_column :guten_books, :rights, :string
    change_column_default :guten_books, :rights, nil
  end
end
