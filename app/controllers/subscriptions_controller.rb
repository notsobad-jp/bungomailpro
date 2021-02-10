require 'google/apis/admin_directory_v1'
require 'googleauth'

class SubscriptionsController < ApplicationController
  def create
    p "create!"
    email = params[:email]
    p email

    scope = [
      'https://www.googleapis.com/auth/admin.directory.group',
      # 'https://www.googleapis.com/auth/admin.directory.member',
    ]
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(ENV['GOOGLE_SERVICE_ACCOUNT_KEY']),
      scope: scope
    )
    authorization.sub = 'info@notsobad.jp'
    service.authorization = authorization

    p service.get_member('test@notsobad.jp', 'info@notsobad.jp')
    p service.list_groups(customer: 'my_customer')

    redirect_to root_path
  end
end
