class Mail::ApplicationController < ApplicationController
  layout 'mail/layouts/application'
  before_action :switch_locale, :require_login, :set_meta_tags

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:warning] = 'Not authorized. Please check your login status.'
    redirect_to(request.referer || login_path)
  end

  def not_authenticated
    flash[:warning] = 'Not authorized. Please signin to see the content.'
    redirect_to login_path
  end

  def set_meta_tags
    @breadcrumbs = [{ name: 'TOP', url: root_url }]
  end

  def switch_locale
    I18n.locale = params[:locale]&.to_sym || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
