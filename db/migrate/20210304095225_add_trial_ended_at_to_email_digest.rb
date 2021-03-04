class AddTrialEndedAtToEmailDigest < ActiveRecord::Migration[6.0]
  def change
    add_column :email_digests, :trial_ended_at, :datetime
    remove_index :email_digests, :updated_at
  end
end
