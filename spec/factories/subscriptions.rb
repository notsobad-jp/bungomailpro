FactoryBot.define do
  factory :subscription do
    association :user, :with_free_membership
    association :channel
  end
end
