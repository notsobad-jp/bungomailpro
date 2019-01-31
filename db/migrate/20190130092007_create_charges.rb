class CreateCharges < ActiveRecord::Migration[5.2]
  def up
    create_table :charges, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.references :user, index: { unique: true }, foreign_key: true, null: false
      t.string :customer_id, index: { unique: true }, null: false
      t.string :brand, null: false, comment: 'IN (American Express, Diners Club, Discover, JCB, MasterCard, UnionPay, Visa, Unknown)'
      t.integer :exp_month, null: false
      t.integer :exp_year, null: false
      t.string :last4, null: false
      t.string :subscription_id, index: { unique: true }
      t.datetime :trial_end
      t.string :status, comment: 'IN (trialing active past_due canceled unpaid)'

      t.timestamps
    end

    # brandの許可リスト
    execute "ALTER TABLE charges ADD CONSTRAINT restrict_brand_values CHECK (brand IN ('American Express', 'Diners Club', 'Discover', 'JCB', 'MasterCard', 'UnionPay', 'Visa', 'Unknown'));"
    # statusの許可リスト
    execute "ALTER TABLE charges ADD CONSTRAINT restrict_status_values CHECK (status IN ('trialing', 'active', 'past_due', 'canceled', 'unpaid'));"
    # subscription_idとstatusが片方だけ入らないように制御
    execute "ALTER TABLE charges ADD CONSTRAINT subscription_constraint CHECK ((subscription_id IS NULL AND status IS NULL) OR (subscription_id IS NOT NULL AND status IS NOT NULL));"
    # exp_month制約
    execute "ALTER TABLE charges ADD CONSTRAINT restrict_exp_month_values CHECK (exp_month >= 1 AND exp_month <= 12);"
    # exp_year制約
    execute "ALTER TABLE charges ADD CONSTRAINT restrict_exp_year_values CHECK (exp_year > 2000 AND exp_year < 3000);"
    # last4制約
    execute "ALTER TABLE charges ADD CONSTRAINT restrict_last4_values CHECK (last4 ~* '^[0-9]{4}$');"
  end

  def down
    drop_table :charges
  end
end
