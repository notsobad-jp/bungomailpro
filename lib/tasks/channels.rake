namespace :channels do
  desc 'FREEユーザーのchannelを削除'
  task destroy_free_channels: :environment do |_task, _args|
    Channel.includes(user: :charge).all.each do |channel|
      unless channel.user.pro?
        p "#{channel.title} destroyed!"
        channel.destroy unless channel.user.pro?
      end
    end
  end
end
