class SearchCondition < ApplicationRecord
  belongs_to :user
  has_many :channels, dependent: :nullify
end
