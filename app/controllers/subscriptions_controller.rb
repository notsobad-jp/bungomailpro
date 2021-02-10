class SubscriptionsController < ApplicationController
  def create
    p "create!"
    email = params[:email]
    p email

    service = GoogleDirectoryService.instance
    p service.get_member('test@notsobad.jp', 'info@notsobad.jp')
    p service.list_groups(customer: 'my_customer')

    redirect_to root_path
  end
end
