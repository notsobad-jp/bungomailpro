class Pixela
  PIXELA_BASE_URL = 'https://pixe.la/v1/users/bungomail/graphs'

  def self.create_graph(user)
    uri = URI.parse(PIXELA_BASE_URL)
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Post.new(uri.path)
    req["X-USER-TOKEN"] = ENV['PIXELA_TOKEN']
    req.body = {
      "id":"#{user.pixela_id}",
      "name":"Bungomail Reading Record",
      "unit":"chapter",
      "type":"int",
      "color":"shibafu",
       "timezone":"Asia/Tokyo"
     }.to_json
    http.request(req)
  end

  def self.increment(user)
    uri = URI.parse("#{PIXELA_BASE_URL}/#{user.pixela_id}/increment")
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Put.new(uri.path)
    req["X-USER-TOKEN"] = ENV['PIXELA_TOKEN']
    req["Content-Length"] = 0

    http.request(req)
  end
end
