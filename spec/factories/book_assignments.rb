FactoryBot.define do
  factory :book_assignment do
    association :channel

    factory :ba_with_aozora do
      after :build do |ba|
        ba.book = build(:aozora_book)
      end
    end

    factory :ba_with_guten do
      after :build do |ba|
        ba.book = build(:guten_book)
      end
    end
  end
end
