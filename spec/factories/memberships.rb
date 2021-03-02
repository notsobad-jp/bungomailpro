FactoryBot.define do
  factory :membership do
    id { create(:user).id }
    plan { 'free' }
  end
end
