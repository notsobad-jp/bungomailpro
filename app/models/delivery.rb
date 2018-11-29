# == Schema Information
#
# Table name: deliveries
#
#  id           :bigint(8)        not null, primary key
#  user_book_id :bigint(8)        not null
#  next_index   :integer          default(1), not null
#  deliver_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Delivery < ApplicationRecord
  belongs_to :subscription
  has_one :user, through: :subscription
  has_one :book, through: :subscription


  def deliver
    UserMailer.with(delivery: self).deliver_chapter.deliver_later
    self.update(delivered: true)

    # 最後の配信なら次の作品をセット
    self.subscription.set_deliveries if !Delivery.find_by(subscription_id: self.subscription_id, delivered: false)
  end

  def last_index
    Delivery.where(subscription_id: self.subscription_id, book_id: self.book_id).maximum(:index)
  end
end
