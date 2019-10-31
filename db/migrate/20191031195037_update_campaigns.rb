class UpdateCampaigns < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :list_id, :integer
    remove_column :campaigns, :user_id, :uuid
    rename_column :campaigns, :plain_content, :content
    add_reference :campaigns, :book, foreign_key: true, null: false
  end
end
