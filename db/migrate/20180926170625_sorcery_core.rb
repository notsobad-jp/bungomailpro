class SorceryCore < ActiveRecord::Migration[5.2]
  def up
    create_table :users do |t|
      t.string :email,            :null => false
      t.string :token,            :null => false
      t.string :crypted_password
      t.string :salt
      t.string :stripe_customer_id
      t.string :stripe_status

      t.timestamps                :null => false
    end

    add_index :users, :email, unique: true
    add_index :users, :token, unique: true

    execute "ALTER TABLE users ADD CONSTRAINT restrict_stripe_status_values CHECK (stripe_status IN ('trialing', 'active', 'past_due', 'canceled', 'unpaid'));"
  end

  def down
    drop_table :users
  end
end
