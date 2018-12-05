namespace :tmp_tasks do
  task :reset_token => :environment do |task, args|
    User.all.each do |user|
      user.token = SecureRandom.hex(10)
      user.save
    end
  end

  task :algolia => :environment do |task, args|
    Algolia.init(
      application_id: 'ZDNL6PSK6G',
      api_key:        'f893fc38e80d8a577ab15be80c46c255'
    )
    index = Algolia::Index.new('books')
    # byebug
  end
end
