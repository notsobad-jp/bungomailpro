FactoryBot.define do
  factory :charge do
    customer_id     { "cus_#{SecureRandom.hex(5)}" }
    subscription_id { "sub_#{SecureRandom.hex(5)}" }
    brand           { "Visa" }
    exp_month       { 12 }
    exp_year        { 2030 }
    last4           { 1234 }
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
  end
end
