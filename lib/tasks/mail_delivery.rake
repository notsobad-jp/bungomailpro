namespace :mail_delivery do
  desc "hourlyのメール送信タスク"
  task :hourly_delivery, ['url'] => :environment do |task, args|
    deliveries = Delivery.where(delivered: false, deliver_at: Time.now - 1.hour .. Time.now)
    deliveries.each do |delivery|
      delivery.deliver
    end
  end
end
