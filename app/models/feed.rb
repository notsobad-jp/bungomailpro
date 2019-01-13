class Feed < ApplicationRecord
  self.primary_key = :subscription_id
  belongs_to :subscription
end
