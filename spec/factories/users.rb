FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com"}

    trait :without_membership do
      before(:create) { |user| user.class.skip_callback(:create, :after, :create_membership) }
      after(:create) { |user| user.class.set_callback(:create, :after, :create_membership) }
    end
  end
end
