FactoryBot.define do
  factory :membership_log do
    membership
    plan { 'free' }
    status { :active }
    apply_at { Time.current.ago(1.hour) }
  end
end
