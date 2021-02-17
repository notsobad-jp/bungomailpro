class CreateMembershipLog < ActiveRecord::Migration[6.0]
  def change
    create_table :membership_logs, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :action, null: false, index: true
      t.string :plan, null: false
      t.string :status, null: false
      t.datetime :apply_at, null: false, index: true, default: -> { 'CURRENT_TIMESTAMP' }
      t.boolean :finished, default: false, null: false
      t.boolean :canceled, default: false, null: false
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end
    remove_column :memberships, :start_at, :datetime
    remove_column :memberships, :trial_end_at, :datetime
    remove_column :memberships, :cancel_at, :datetime
  end
end
