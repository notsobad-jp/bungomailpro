class DropCountAndAddEndDateToBookAssignment < ActiveRecord::Migration[6.0]
  CONSTRAINT_NAME = "gist_index_book_assignments_on_delivery_period"

  def up
    sql = "ALTER TABLE book_assignments DROP CONSTRAINT #{CONSTRAINT_NAME};"
    add_column :book_assignments, :end_date, :date
    sql += "UPDATE book_assignments SET end_date = start_date + INTERVAL '1 days' * (count - 1);"
    sql += "ALTER TABLE book_assignments ADD CONSTRAINT #{CONSTRAINT_NAME} EXCLUDE USING gist (channel_id WITH =, daterange(start_date, end_date) WITH &&);"
    ActiveRecord::Base.connection.execute(sql)
    change_column_null :book_assignments, :end_date, false
    add_index :book_assignments, :end_date
    remove_column :book_assignments, :count
  end

  def down
    sql = "ALTER TABLE book_assignments DROP CONSTRAINT #{CONSTRAINT_NAME};"
    add_column :book_assignments, :count, :integer
    sql += "UPDATE book_assignments SET count = end_date - start_date + 1;"
    sql += "ALTER TABLE book_assignments ADD CONSTRAINT #{CONSTRAINT_NAME} EXCLUDE USING gist (channel_id WITH =, daterange(start_date, date(start_date + (count-1) * INTERVAL '1 day')) WITH &&);"
    ActiveRecord::Base.connection.execute(sql)
    change_column_null :book_assignments, :count, false
    remove_column :book_assignments, :end_date
  end
end
