class AddTwitterShareUrlToCampaignGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :campaign_groups, :twitter_share_url, :string
  end
end
