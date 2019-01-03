class SubscriptionsController < ApplicationController
  before_action :require_login, except: [:index]
  before_action :authorize_subscription, only: [:index]
  # before_action :set_subscription, only: [:destroy, :update, :skip, :deliver, :show]
  after_action :verify_authorized

  def index
    @subscriptions = current_user.subscriptions.includes(:channel, next_chapter: :book, last_chapter: :book) if current_user
  end


  private
    def authorize_subscription
      authorize Subscription
    end
end
