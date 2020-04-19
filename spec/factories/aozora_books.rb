FactoryBot.define do
  factory :aozora_book do
    sequence(:id) { |n| n }
    sequence(:title) { |n| "Title #{n}"}
    sequence(:author) { |n| "Author #{n}"}
  end
end
