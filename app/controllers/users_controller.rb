class UsersController < ApplicationController
  before_action :require_login
  before_action :set_user
  after_action :verify_authorized

  def show
    @breadcrumbs << { name: 'アカウント情報' }
    @charge = @user.charge
    if @charge.try(:status) == "trialing"
      sub = Stripe::Subscription.retrieve(@charge.subscription_id)
      @trial_end = Time.zone.at(sub.trial_end)
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end
end
