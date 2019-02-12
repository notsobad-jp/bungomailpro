class UsersController < ApplicationController
  before_action :require_login
  before_action :set_user
  after_action :verify_authorized

  def show
    @breadcrumbs << { name: 'アカウント情報' }
    @charge = @user.charge
  end

  private

  def set_user
    @user = User.find(params[:id])
    authorize @user
  end
end
