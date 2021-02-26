FactoryBot.define do
  factory :membership do
    id { create(:user, :without_membership).id }
    plan { 'free' }
    status { :active }
  end
end
