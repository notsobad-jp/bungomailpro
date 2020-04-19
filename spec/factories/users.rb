FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "hoge#{n}@example.com"}
  end
end
