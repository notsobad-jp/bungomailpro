class UsersController < ApplicationController
  before_action :require_login
  before_action :set_user
  after_action :verify_authorized

  def show
    @breadcrumbs << { name: 'アカウント情報' }
    @charge = @user.charge
    @stripe_sub = Stripe::Subscription.retrieve(@charge.subscription_id) if @charge.try(:status) == 'trialing'
  end

  def pixela
    if params[:logging] == 'true'
      @user.update(pixela_logging: true)
      res = Pixela.create_graph(@user)
      logger.info "[PIXELA] Created graph for #{@user.id}, #{res}"
      flash[:success] = '読書ログを有効化しました🎉'
    else
      @user.update(pixela_logging: false)
      flash[:success] = '読書ログを停止しました'
    end
    redirect_to user_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end
end
