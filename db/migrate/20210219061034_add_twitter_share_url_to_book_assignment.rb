class AddTwitterShareUrlToBookAssignment < ActiveRecord::Migration[6.0]
  def change
    add_column :book_assignments, :twitter_share_url, :string
  end
end
