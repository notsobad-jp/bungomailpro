class En::PagesController < En::ApplicationController
  skip_before_action :require_login

  def lp
    flash[:success] = "Your account has been successfully saved! The email will be delivered from tomorrow and we hope you like it :)" if params[:success]
    render layout: false
  end
end
