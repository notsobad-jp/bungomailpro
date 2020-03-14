class RemoveChaptersCountAndGroupFromBook < ActiveRecord::Migration[6.0]
  def change
    remove_column :books, :chapters_count, :integer, default: 0
    remove_column :books, :group, :string
  end
end
