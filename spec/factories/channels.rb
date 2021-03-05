FactoryBot.define do
  factory :channel do
    association :user, :with_basic_membership
  end

  trait :with_book_assignment do
    after(:create) do |channel|
      channel.book_assignments << create(:book_assignment, :with_book)
    end
  end

  trait :with_google_group do
    after(:create) do |channel|
      channel.channel_profile = create(:channel_profile, google_group_key: 'test@notsobad.jp')
    end
  end
end
