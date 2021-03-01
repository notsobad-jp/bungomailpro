class DestroyAllRecordsOnUserDestroy < ActiveRecord::Migration[6.0]
  def up
    create_table :email_digests, id: false do |t|
      t.string :digest, null: false, primary_key: true
      t.datetime :deleted_at
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    remove_column :memberships, :status, :integer, null: false, default: 1
    add_column :memberships, :trialing, :boolean, null: false, default: false
    execute "ALTER TABLE memberships ADD CONSTRAINT chk_plan_trialability CHECK (plan <> 'free' OR trialing = false)"

    remove_column :membership_logs, :status, :integer, null: false, default: 1
    add_column :membership_logs, :trialing, :boolean, null: false, default: false
    execute "ALTER TABLE membership_logs ADD CONSTRAINT chk_plan_trialability CHECK (plan <> 'free' OR trialing = false)"
  end

  def down
    drop_table :email_digests

    execute "ALTER TABLE memberships DROP CONSTRAINT chk_plan_trialability"
    add_column :memberships, :status, :integer, null: false, default: 1
    remove_column :memberships, :trialing, :boolean, null: false, default: false

    execute "ALTER TABLE membership_logs DROP CONSTRAINT chk_plan_trialability"
    add_column :membership_logs, :status, :integer, null: false, default: 1
    remove_column :membership_logs, :trialing, :boolean, null: false, default: false
  end
end
