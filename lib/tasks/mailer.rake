namespace :mailer do
  desc "テスト送信"
  task :tmp_deliver, ['delivery_id'] => :environment do |task, args|
    delivery = Delivery.find(args[:delivery_id])
    delivery.deliver
    p "delivered #{delivery.id}"
  end

  desc "レギュラーのメール送信タスク"
  task :deliver => :environment do |task, args|
    deliveries = Delivery.where(delivered: false, deliver_at: Time.now - 1.hour .. Time.now)
    deliveries.each do |delivery|
      delivery.deliver
      p "delivered #{delivery.id}"
    end
  end
end
