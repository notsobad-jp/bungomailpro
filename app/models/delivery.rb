# == Schema Information
#
# Table name: deliveries
#
#  id              :bigint(8)        not null, primary key
#  subscription_id :bigint(8)
#  book_id         :bigint(8)
#  index           :integer          not null
#  text            :text
#  deliver_at      :datetime
#  delivered       :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Delivery < ApplicationRecord
  belongs_to :user_book
  has_one :user, through: :user_book
  has_one :book, through: :user_book


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
