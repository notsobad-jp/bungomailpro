FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test-{n}@example.com"}
    after(:build) do |user|
      # TODO: build membership
    end
  end
end
