class CreatePausedLog < ActiveRecord::Migration[6.0]
  def change
    create_table :paused_logs, id: :uuid do |t|
      t.string :email, null: false
      t.string :month, null: false
      t.timestamps
    end
    add_index :paused_logs, [:email, :month], unique: true
  end
end
