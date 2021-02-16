class MembershipLog < ApplicationRecord
  belongs_to :user
  belongs_to :delayed_job, required: false

  after_destroy do
    self.delayed_job&.delete
  end
end
