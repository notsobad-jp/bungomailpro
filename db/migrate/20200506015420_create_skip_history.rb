class CreateSkipHistory < ActiveRecord::Migration[6.0]
  def change
    create_table :skip_histories, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.timestamps
    end
  end
end
