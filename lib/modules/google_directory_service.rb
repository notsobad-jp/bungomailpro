require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'singleton'

class GoogleDirectoryService < Google::Apis::AdminDirectoryV1::DirectoryService
  include Singleton

  def initialize
    super

    scope = [
      'https://www.googleapis.com/auth/admin.directory.group',
      # 'https://www.googleapis.com/auth/admin.directory.member',
    ]
    auth = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(ENV['GOOGLE_SERVICE_ACCOUNT_KEY']),
      scope: scope
    )
    auth.sub = 'info@notsobad.jp'
    self.authorization = auth
  end
end
