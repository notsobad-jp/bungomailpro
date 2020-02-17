class AssociateFeedToAssignedBook < ActiveRecord::Migration[5.2]
  def change
    remove_reference :feeds, :user, type: :uuid, foreign_key: true, null: false
    remove_reference :feeds, :guten_book, foreign_key: true, null: false
    add_reference :feeds, :assigned_book, type: :uuid, foreign_key: true, null: false
  end
end
