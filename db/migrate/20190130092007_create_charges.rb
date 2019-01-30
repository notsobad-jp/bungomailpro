class CreateCharges < ActiveRecord::Migration[5.2]
  def up
    create_table :charges, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.references :user, index: { unique: true }, foreign_key: true, null: false
      t.string :customer_id, index: { unique: true }, null: false
      t.string :subscription_id, index: { unique: true }
      t.string :status
      t.datetime :trial_end

      t.timestamps
    end
    execute "ALTER TABLE charges ADD CONSTRAINT restrict_status_values CHECK (status IN ('trialing', 'active', 'past_due', 'canceled', 'unpaid'));"
    # subscription_idとstatusが片方だけ入らないように制御
    execute "ALTER TABLE charges ADD CONSTRAINT subscription_constraint CHECK ((subscription_id IS NULL AND status IS NULL) OR (subscription_id IS NOT NULL AND status IS NOT NULL));"
  end

  def down
    drop_table :charges
  end
end
