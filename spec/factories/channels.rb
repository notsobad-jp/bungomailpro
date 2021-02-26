FactoryBot.define do
  factory :channel do
    association :user, :with_basic_membership
  end
end
