class BookVariant < ApplicationRecord
  belongs_to :standard, foreign_key: :standard_book_id, class_name: 'AozoraBook'
  belongs_to :variant, foreign_key: :variant_book_id, class_name: 'AozoraBook'
end
