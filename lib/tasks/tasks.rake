include ActionView::Helpers::TextHelper

namespace :tasks do
  task create_campaigns: :environment do |_task, _args|
    book = Book.find(ENV['BOOK_ID'])
    res = book.create_campaigns(ENV['COUNT'])
    Campaign.find(res.ids).each do |campaign|
      campaign.
    end
  end
end
