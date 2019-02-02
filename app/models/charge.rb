# == Schema Information
#
# Table name: charges
#
#  id                                                                                            :string           not null, primary key
#  user_id                                                                                       :bigint(8)        not null
#  customer_id                                                                                   :string           not null
#  brand(IN (American Express, Diners Club, Discover, JCB, MasterCard, UnionPay, Visa, Unknown)) :string           not null
#  exp_month                                                                                     :integer          not null
#  exp_year                                                                                      :integer          not null
#  last4                                                                                         :string           not null
#  subscription_id                                                                               :string
#  status(IN (trialing active past_due canceled unpaid))                                         :string
#  trial_end                                                                                     :datetime
#  cancel_at                                                                                     :datetime
#  created_at                                                                                    :datetime         not null
#  updated_at                                                                                    :datetime         not null
#

class Charge < ApplicationRecord
  belongs_to :user

  before_create do
    self.id = SecureRandom.hex(10)
  end
end
