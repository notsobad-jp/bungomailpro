class ApplicationController < ActionController::Base
  protect_from_forgery
  include Pundit

  before_action :set_meta_tags
  before_action :redirect_to_custom_domain

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found


  private

  def user_not_authorized
    flash[:error] = '権限がありません。ログイン状態を確認してください。'
    redirect_to request.referer || pro_root_path, status: 403
  end

  def not_authenticated
    flash[:error] = 'ログインしてください'
    redirect_to login_path, status: 401
  end

  def not_found
    flash[:error] = 'ページが見つかりませんでした'
    logger.warn "[NOT FOUND] #{request.url}"
    redirect_to pro_root_path, status: 404
  end

  # herokuapp.comドメインでアクセスが来たらカスタムドメインにリダイレクト
  def redirect_to_custom_domain
    redirect_to 'https://bungomail.com' + request.path, status: 301 if request.host.include? 'bungomail.herokuapp.com'
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
