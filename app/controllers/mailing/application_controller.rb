class Mailing::ApplicationController < ApplicationController
  layout 'mailing/layouts/application'
  before_action :switch_locale, :require_login, :set_meta_tags, :set_alert_message

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
    locale = :en if I18n.locale == :en
    { locale: locale }
  end

  # 未課金ユーザーに警告表示
  def set_alert_message
    return if !current_user || current_user.charge&.active?

    @alert_message =  if current_user.before_trial?
                        "無料トライアルは『#{current_user.trial_start_at.strftime('%-m月%-d日')}』から始まります。いますぐに開始したい場合はマイページで設定を変更してください（作品途中からの配信になります）"
                      elsif current_user.trialing?
                        "無料トライアルは『#{current_user.trial_end_at.strftime('%-m月%-d日')}』で終了します。翌月以降もメールを受信するためには、決済情報を登録してください。"
                      end
  end
end
