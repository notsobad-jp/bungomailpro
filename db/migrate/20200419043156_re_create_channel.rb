class ReCreateChannel < ActiveRecord::Migration[6.0]
  def change
    create_table :channels, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.string :title, null: false
      t.text :description
      t.boolean :active, null: false, default: false
      t.boolean :public, null: false, default: false

      t.timestamps
    end
  end
end
