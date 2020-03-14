class AddRightsReservedToBook < ActiveRecord::Migration[6.0]
  def change
    add_column :books, :rights_reserved, :boolean, default: false
  end
end
