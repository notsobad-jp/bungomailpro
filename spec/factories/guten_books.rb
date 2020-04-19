FactoryBot.define do
  factory :guten_book do
    sequence(:title) { |n| "Title #{n}"}
    sequence(:author) { |n| "Author #{n}"}
  end
end
