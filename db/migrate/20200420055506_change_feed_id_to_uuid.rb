class ChangeFeedIdToUuid < ActiveRecord::Migration[6.0]
  def up
    remove_column :feeds, :id, :primary_key, auto_increment: true
    add_column :feeds, :id, :uuid, default: "gen_random_uuid()"
    execute "ALTER TABLE feeds ADD PRIMARY KEY (id);"
  end

  def down
    remove_column :feeds, :id
    add_column :feeds, :id, :primary_key, auto_increment: true
  end
end
