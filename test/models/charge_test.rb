# == Schema Information
#
# Table name: charges
#
#  id              :string           not null, primary key
#  user_id         :bigint(8)        not null
#  customer_id     :string           not null
#  brand           :string           not null
#  exp_month       :integer          not null
#  exp_year        :integer          not null
#  last4           :string           not null
#  subscription_id :string
#  status          :string
#  trial_end       :datetime
#  cancel_at       :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class ChargeTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:user1)

    stub_request(:any, /https:\/\/api\.stripe\.com\/*/).to_return(
      status: 200,
      body: "",
      headers: {}
    )
  end

  test "test_charge" do
    cus_id = 'cus_ES96GGaeWWu7hM'
    customer = Stripe::Customer.retrieve(cus_id)
    p customer
  end
end
