FactoryBot.define do
  factory :book_assignment do
    association :channel
    book_id { 1567 }
    book_type { 'AozoraBook' }
    start_date { Time.zone.today.next_month.beginning_of_month }
    end_date { start_date + 29 }

    trait :with_book do
      before(:create) { create(:aozora_book) }
    end
  end
end
