class CreateCampaignGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :campaign_groups do |t|
      t.references :book, foreign_key: true, null: false
      t.integer :count, null: false
      t.datetime :start_at, null: false
      t.integer :list_id, null: false
      t.integer :sender_id, null: false
      t.timestamps
    end
  end
end
