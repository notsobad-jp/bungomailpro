class DropCategory < ActiveRecord::Migration[6.0]
  def up
    remove_foreign_key :aozora_books, :categories
    drop_table :categories
  end

  def down
    fail ActiveRecord::IrreversibleMigration
    # add_foreign_key :aozora_books, :categories
  end
end
