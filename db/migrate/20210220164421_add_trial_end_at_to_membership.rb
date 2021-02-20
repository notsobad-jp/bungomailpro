class AddTrialEndAtToMembership < ActiveRecord::Migration[6.0]
  def change
    add_column :memberships, :trial_end_at, :datetime
    add_index :memberships, :trial_end_at
    add_index :memberships, :plan
    add_index :memberships, :status
  end
end
