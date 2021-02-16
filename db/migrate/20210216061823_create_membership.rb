class CreateMembership < ActiveRecord::Migration[6.0]
  def change
    create_table :memberships, id: :uuid do |t|
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.string :plan, default: 'free', null: false
      t.string :status, default: 'before_trial', null: false
      t.datetime :start_at, null: false
      t.datetime :trial_end_at
      t.datetime :cancel_at
      t.timestamps
    end
    add_foreign_key :memberships, :users, column: :id
  end
end
