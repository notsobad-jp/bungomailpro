class Mail::ApplicationController < ApplicationController
  layout 'mail/layouts/application'
  before_action :redirect_to_custom_domain, :switch_locale, :require_login, :set_meta_tags

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # herokuapp.comドメインでアクセスが来たらカスタムドメインにリダイレクト
  def redirect_to_custom_domain
    redirect_to 'https://bungomail.com' + request.path, status: :moved_permanently if request.host.include? 'bungomail.herokuapp.com'
  end

  def user_not_authorized
    flash[:warning] = 'Not authorized. Please check your login status.'
    redirect_to(request.referer || root_path)
  end

  def not_authenticated
    flash[:warning] = 'Not authorized. Please signin to see the content.'
    redirect_to login_path
  end

  def set_meta_tags
    @breadcrumbs = [{ name: 'HOME', url: root_url }]
  end

  def switch_locale
    I18n.locale = params[:locale]&.to_sym || I18n.default_locale
    book_class = I18n.locale == :ja ? AozoraBook : GutenBook
    Object.const_set :Book, Class.new(book_class)
  end
end
