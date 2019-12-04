class ReferenceCampaignsToCampaignGroup < ActiveRecord::Migration[5.2]
  def change
    remove_column :campaigns, :book_id, :integer
    add_reference :campaigns, :campaign_group, foreign_key: true, null: false, default: 1
  end
end
