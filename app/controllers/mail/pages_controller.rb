class Mail::PagesController < Mail::ApplicationController
  skip_before_action :require_login

  def lp
    render layout: false
  end
end