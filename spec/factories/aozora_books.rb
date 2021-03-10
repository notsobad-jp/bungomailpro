FactoryBot.define do
  factory :aozora_book do
    sequence(:id) { |n| n }
    sequence(:title) { |n| "book#{n}" }
    sequence(:author_id) { |n| n }
    sequence(:author) { |n| "author#{n}" }
    sequence(:file_id) { |n| n }

    factory :aozora_book_meros do
      id { 1567 }
      title { '走れメロス' }
      author { '太宰治' }
      author_id { 35 }
      file_id { 14913 }
    end
  end
end
