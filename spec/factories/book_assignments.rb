FactoryBot.define do
  factory :book_assignment do
    association :channel
    book_id { 1567 }
    book_type { 'AozoraBook' }
    count { 30 }
    start_date { Time.zone.tomorrow }

    trait :with_book do
      before(:create) { create(:aozora_book) }
    end
  end
end
