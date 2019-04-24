class AddPixelaToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pixela_logging, :boolean, default: false
  end
end
