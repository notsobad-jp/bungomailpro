FactoryBot.define do
  factory :channel_profile do
    association :channel
    sequence(:title) { |n| "channel#{n}"}
  end
end
