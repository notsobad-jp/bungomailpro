FactoryBot.define do
  factory :search_condition do
    association :user
    query { { author: "Janeway" } }
    book_type { "GutenBook" }
    book_ids { [30645] }
  end
end
