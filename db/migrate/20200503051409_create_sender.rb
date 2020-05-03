class CreateSender < ActiveRecord::Migration[6.0]
  def change
    create_table :senders, id: false do |t|
      t.integer :id, primary_key: true
      t.string :nickname, null: false
      t.string :name, null: false
      t.date :locked_until
      t.timestamps

      t.index :locked_until
    end
    change_column_default :senders, :created_at, from: nil, to: -> { 'now()' }
    change_column_default :senders, :updated_at, from: nil, to: -> { 'now()' }
  end
end
