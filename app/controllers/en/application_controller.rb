class En::ApplicationController < ApplicationController
  layout 'en/layouts/application'
  before_action :require_login, :switch_locale

  def switch_locale
    I18n.locale = :en
    book_class = GutenBook
    Object.const_set :Book, Class.new(book_class)
  end
end
