FactoryBot.define do
  factory :membership_log do
    user
    membership
    plan { 'free' }
    status { :active }

    trait :free do
      plan { 'free' }
    end

    trait :basic do
      plan { 'basic' }
    end

    trait :active do
      status { :active }
    end

    trait :trialing do
      status { :trialing }
    end

    trait :canceled do
      status { :canceled }
    end
  end
end
