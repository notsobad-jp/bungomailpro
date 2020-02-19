class AddDefaultTimestamp < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :created_at, from: nil, to: -> { 'now()' }
    change_column_default :users, :updated_at, from: nil, to: -> { 'now()' }
    change_column_default :campaign_groups, :created_at, from: nil, to: -> { 'now()' }
    change_column_default :campaign_groups, :updated_at, from: nil, to: -> { 'now()' }
  end
end
