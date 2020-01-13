class DeleteColumnFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :admin
    remove_column :users, :category
    remove_column :users, :pixela_logging
  end
end
