VCR.configure do |c|
    c.cassette_library_dir = 'spec/vcr'
    c.hook_into :webmock
    c.ignore_localhost = true
    c.filter_sensitive_data('<SENDGRID_API_KEY>') { ENV['SENDGRID_API_KEY'] }
    c.default_cassette_options = {
      record: :once,
      match_requests_on: [:method, :uri, :body],
    }
end
