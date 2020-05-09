VCR.configure do |c|
    c.cassette_library_dir = 'spec/vcr'
    # c.configure_rspec_metadata!
    c.hook_into :webmock
    c.ignore_localhost = true
    c.default_cassette_options = {
      record: :once,
      match_requests_on: [:method, :uri, :body],
    }
end
