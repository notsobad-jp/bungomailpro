FactoryBot.define do
  factory :channel do
    sequence(:title) { |n| "Title #{n}"}
    association :user
  end
end
