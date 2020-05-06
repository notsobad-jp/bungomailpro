class ChangeBookAssignment < ActiveRecord::Migration[6.0]
  def change
    remove_reference :book_assignments, :user, type: :uuid, foreign_key: true, null: false
    remove_reference :book_assignments, :guten_book, foreign_key: true, null: false

    add_reference :book_assignments, :book, polymorphic: true
    add_reference :book_assignments, :channel, type: :uuid, foreign_key: true, null: false
    # add_index :book_assignments, [:channel_id, :status], where: '"status" = 1', unique: true
  end
end
