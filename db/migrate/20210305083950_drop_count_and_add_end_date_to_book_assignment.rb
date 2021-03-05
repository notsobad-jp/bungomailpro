class DropCountAndAddEndDateToBookAssignment < ActiveRecord::Migration[6.0]
  def up
    add_column :book_assignments, :end_date, :date
    # ここでデータmigration実行: count -> end_date
    # change_column_null :book_assignments, :end_date, false
    # remove_column :book_assignments, :count
  end

  def down
    # add_column :book_assignments, :count, :integer
    # # ここでデータmigration実行: end_date -> count
    # change_column_null :book_assignments, :count, false
    remove_column :book_assignments, :end_date
  end
end
