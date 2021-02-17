class UpdateChannelProfile < ActiveRecord::Migration[6.0]
  def change
    rename_column :channel_profiles, :send_to, :google_group_key
    change_column_null :channel_profiles, :title, false
  end
end
