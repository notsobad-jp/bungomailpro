FactoryBot.define do
  factory :membership_log do
    membership
    plan { 'free' }
    status { :active }
  end
end
