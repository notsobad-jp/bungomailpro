class DeliveriesController < ApplicationController
  def index
    @deliveries = current_user.deliveries
  end
end
