namespace :tmp_tasks do
  task :reset_token => :environment do |task, args|
    User.all.each do |user|
      user.token = SecureRandom.hex(10)
      user.save
    end
  end
end
