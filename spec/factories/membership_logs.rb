FactoryBot.define do
  factory :membership_log do
    membership
    plan { 'free' }
    apply_at { Time.current.ago(1.hour) }
  end
end
