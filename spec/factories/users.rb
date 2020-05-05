FactoryBot.define do
  # デフォルトは、activate済み（Sendgridにもcustomer追加済み）&& トライアル開始前のものを作成
  factory :user do
    sequence(:email)       { |n| "hoge#{n}@example.com"}
    activation_state       { "active" }
    sequence(:sendgrid_id) { |n| "sendgrid#{n}"}
    trial_end_at           { Time.current.next_month.end_of_month }

    trait :not_activated do
      activation_state { "pending" }
      sendgrid_id      { nil }
    end

    trait :trialing do
      trial_end_at { Time.current.end_of_month }
    end

    trait :trial_ended do
      trial_end_at { Time.current.last_month.end_of_month }
    end

    trait :list_subscribed do
      list_subscribed { true }
    end

    trait :with_active_charge do
      after(:build) do |user|
        build(:charge, user: user)
      end
    end

    trait :with_trialing_charge do
      after(:build) do |user|
        build(:charge, :trialing, user: user)
      end
    end

    trait :with_canceled_charge do
      after(:build) do |user|
        build(:charge, :canceled, user: user)
      end
    end

    trait :with_past_due_charge do
      after(:build) do |user|
        build(:charge, :past_due, user: user)
      end
    end

    factory :user_not_activated,           traits: [:not_activated]
    factory :user_trialing_without_charge, traits: [:trialing, :list_subscribed]
    factory :user_trialing_with_charge,    traits: [:trialing, :list_subscribed, :with_trialing_charge]
    factory :user_subscribing_with_charge, traits: [:trial_ended, :list_subscribed, :with_active_charge]
    factory :user_paused_with_charge,      traits: [:trial_ended, :with_active_charge]
    factory :user_paused_without_charge,   traits: [:trial_ended, :with_canceled_charge]
  end
end
