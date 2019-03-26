class AddHashtagToChannel < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :hashtag, :string
    add_column :channels, :from_name, :string
    add_column :channels, :from_email, :string
  end
end
