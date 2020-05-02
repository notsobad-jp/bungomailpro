class DropUserI18nColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :locale, :string, default: 'ja', null: false
    remove_column :users, :timezone, :string, default: 'UTC', null: false
  end
end
