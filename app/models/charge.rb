class Charge < ApplicationRecord
  belongs_to :user

  before_create do
    self.id = SecureRandom.hex(10)
  end
end
