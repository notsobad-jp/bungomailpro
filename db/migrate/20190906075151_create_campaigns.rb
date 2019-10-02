class CreateCampaigns < ActiveRecord::Migration[5.2]
  def change
    create_table :campaigns do |t|
      t.integer :sendgrid_id
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.string :title, null: false
      t.text :plain_content, null: false
      t.datetime :send_at, null: false
      t.timestamps
    end
    add_index :campaigns, :sendgrid_id, unique: true
  end
end
