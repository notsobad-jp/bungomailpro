class UsersController < ApplicationController
  before_action :require_login
  before_action :set_user, only: [:show]
  after_action :verify_authorized

  def show
  end

  private
    def set_user
      @user = User.find_by_token(params[:token])
      authorize @user
    end

    def authorize_user
      authorize User
    end
end
