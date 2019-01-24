class ApplicationController < ActionController::Base
  protect_from_forgery
  include Pundit

  before_action :set_meta_tags
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private
    def user_not_authorized
      flash[:warning] = "権限がありません。ログイン状態を確認してください。"
      redirect_to(request.referrer || pro_root_path)
    end
    def not_authenticated
      flash[:error] = 'ログインしてください'
      redirect_to login_path
    end

    # メタタグ設定
    ## 基本は静的なのでlocales/meta.ja.ymlから読み込み
    ## 動的に設定するパラメータは各controllerで設定
    def set_meta_tags
      @meta_title       = t('.title')
      @meta_description = t('.description')
      @meta_noindex     = t('.noindex') == true
      @breadcrumbs      = []
    end
end
