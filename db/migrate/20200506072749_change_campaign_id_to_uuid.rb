class ChangeCampaignIdToUuid < ActiveRecord::Migration[6.0]
  # campaignsとcampaign_groupsのidをuuidにして、foreign_keyもuuidに変更
  def up
    remove_foreign_key :campaigns, :campaign_groups
    execute 'ALTER TABLE campaign_groups ALTER COLUMN id DROP DEFAULT, ALTER COLUMN id TYPE uuid USING (gen_random_uuid()), ALTER COLUMN id SET DEFAULT gen_random_uuid()'
    execute 'ALTER TABLE campaigns ALTER COLUMN id DROP DEFAULT, ALTER COLUMN id TYPE uuid USING (gen_random_uuid()), ALTER COLUMN id SET DEFAULT gen_random_uuid()'
    execute 'ALTER TABLE campaigns ALTER COLUMN campaign_group_id DROP DEFAULT, ALTER COLUMN campaign_group_id TYPE uuid USING (gen_random_uuid())'
    add_foreign_key :campaigns, :campaign_groups
  end

  def down
    raise 'Cannot rollback!'
  end
end
