class DelayedJob < ApplicationRecord
  has_one :chapter, dependent: :nullify
end
