class AddTypeToUser < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :category, :string, comment: 'IN (admin partner)'
    execute "ALTER TABLE users ADD CONSTRAINT restrict_category_values CHECK (category IN ('admin', 'partner'));"
  end

  def down
    remove_column :users, :category
  end
end
