class DelayedJob < ApplicationRecord
  has_one :chapter, dependent: :nullify
  has_one :membership_log, dependent: :nullify
end
