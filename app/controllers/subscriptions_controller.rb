require 'google/apis/admin_directory_v1'
require 'googleauth'

class SubscriptionsController < ApplicationController
  def create
    p "create!"
    email = params[:email]
    p email

    scope = ['https://www.googleapis.com/auth/admin.directory.group']
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    # authorization = Google::Auth::ServiceAccountCredentials.make_creds(
    #   json_key_io: File.open('tmp/client_secrets.json'),
    #   scope: scope
    # )
    ENV['GOOGLE_APPLICATION_CREDENTIALS']  = "tmp/client_secrets.json"
    authorization = Google::Auth.get_application_default(scope).dup

    authorization.sub = 'info@notsobad.jp'
    service.authorization = authorization

    p service.list_groups(customer: 'my_customer')

    redirect_to root_path
  end
end
