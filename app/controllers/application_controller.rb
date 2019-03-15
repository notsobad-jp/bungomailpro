class ApplicationController < ActionController::Base
  protect_from_forgery
  include Pundit

  before_action :set_meta_tags
  before_action :redirect_to_custom_domain

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound,     with: :render_404
  rescue_from ActionController::RoutingError,   with: :render_404

  private

  def user_not_authorized
    flash[:warning] = '権限がありません。ログイン状態を確認してください。'
    redirect_to(request.referer || pro_root_path)
  end

  def not_authenticated
    flash[:error] = 'ログインしてください'
    redirect_to login_path
  end

  # herokuapp.comドメインでアクセスが来たらカスタムドメインにリダイレクト
  def redirect_to_custom_domain
    redirect_to 'https://bungomail.com' + request.path, status: :moved_permanently if request.host.include? 'bungomail.herokuapp.com'
  end

  def render_404(error = nil)
    logger.info "[404] Rendering 404 with exception: #{error.message}" if error
    render file: Rails.root.join("public", "404.html"), layout: false, status: :not_found
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
