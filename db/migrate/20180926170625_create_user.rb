class CreateUser < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.string :crypted_password
      t.string :salt

      t.string :magic_login_token, default: nil
      t.datetime :magic_login_token_expires_at, default: nil
      t.datetime :magic_login_email_sent_at, default: nil

      t.string :remember_me_token, default: nil
      t.datetime :remember_me_token_expires_at, default: nil

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :token, unique: true
    add_index :users, :magic_login_token
    add_index :users, :remember_me_token
  end
end
