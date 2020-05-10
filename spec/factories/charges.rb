FactoryBot.define do
  factory :charge do
    customer_id     { "cus_#{SecureRandom.hex(5)}" }
    subscription_id { "sub_#{SecureRandom.hex(5)}" }
    brand           { "Visa" }
    exp_month       { 1 }
    exp_year        { 2030 }
    last4           { 4242 }
    status          { "active" }
    trial_end       { Time.current.last_month.end_of_month }

    trait :trialing do
      status    { "trialing" }
      trial_end { Time.current.end_of_month }
    end

    trait :canceled do
      status { "canceled" }
    end

    trait :past_due do
      status { "past_due" }
    end

    trait :with_user do
      user { build(:user) }
    end

    trait :test_customer do
      customer_id { 'cus_HFdJZzJpmXdQd8' }
    end

    trait :no_customer do
      customer_id     { nil }
      brand           { nil }
      exp_month       { nil }
      exp_year        { nil }
      last4           { nil }
    end

    trait :no_subscription do
      subscription_id { nil }
      status          { nil }
      trial_end       { nil }
    end
  end
end
