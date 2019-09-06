class CreateCampaigns < ActiveRecord::Migration[5.2]
  def change
    create_table :campaigns do |t|
      t.integer :sendgrid_id
      t.string :title, null: false
      t.string :subject, null: false
      t.text :html_content
      t.text :plain_content
      t.integer :sender_id
      t.integer :list_id
      t.string :custom_unsubscribe_url
    end
    add_index :campaigns, :sendgrid_id
  end
end
