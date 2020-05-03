class AddSendgridIdToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :sendgrid_id, :string
    add_column :users, :trial_end_at, :datetime
    add_column :users, :list_subscribed, :boolean, default: false
    add_index :users, :sendgrid_id, unique: true
    add_index :users, :trial_end_at
  end
end
