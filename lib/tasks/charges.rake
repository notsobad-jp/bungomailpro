namespace :charges do
  desc 'ベータ版ユーザーのトライアルを３月末までに延長'
  task beta_privilege: :environment do |_task, _args|
    Charge.eager_load(:user).where('users.created_at <= ?', Time.zone.parse('2019-02-27')).each do |charge|
      trial_end = Time.zone.parse('2019-03-31').end_of_day

      sub = Stripe::Subscription.retrieve(charge.subscription_id)
      sub.trial_end = trial_end.to_i
      sub.save

      charge.update!(trial_end: trial_end)
    rescue StandardError => error
      Logger.new(STDOUT).error "[ERROR]charge_id:#{charge.id}, #{error}"
    end
  end
end
