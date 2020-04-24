class AddSearchConditionIdToChannel < ActiveRecord::Migration[6.0]
  def change
    add_reference :channels, :search_condition, type: :uuid, foreign_key: true
  end
end
