FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com"}

    trait :with_free_membership do
      after(:create) do |user|
        Membership.insert({id: user.id, plan: 'free', trialing: false})
      end
    end

    trait :with_trialing_membership do
      after(:create) do |user|
        Membership.insert({id: user.id, plan: 'basic', trialing: true})
      end
    end

    trait :with_basic_membership do
      after(:create) do |user|
        Membership.insert({id: user.id, plan: 'basic', trialing: false})
      end
    end

    trait :with_juvenile_sub do
      after(:create) do |user|
        Subscription.insert({user_id: user.id, channel_id: Channel::JUVENILE_CHANNEL_ID})
      end
    end

    trait :with_official_sub do
      after(:create) do |user|
        Subscription.insert({user_id: user.id, channel_id: Channel::OFFICIAL_CHANNEL_ID})
      end
    end
  end
end
