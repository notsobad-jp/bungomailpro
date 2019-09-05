class Sendgrid
  attr_accessor :title, :subject, :html_content, :plain_content, :sender_id, :list_ids, :custom_unsubscribe_url, :id

  API_BASE_URL = 'https://api.sendgrid.com/v3/'

  def initialize(args)
    args.each do |key, value|
      self.instance_variable_set("@#{key}", value)
    end
  end

  # 汎用APIcall
  def self.call(method: :post, path: "", params: nil)
    uri = URI.join(API_BASE_URL, path)
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP.const_get(method.to_s.capitalize).new(uri.path)
    req["authorization"] = "Bearer #{ENV['SENDGRID_API_KEY']}"
    req["content-type"] = 'application/json'
    req.body = params.to_json if params

    http.request(req)
  end

  # campaign作成
  def create
    self.class.call(path: "campaigns", params: JSON.parse(self.to_json))
  end

  def schedule(send_at)
    self.class.call(path: "campaigns/#{self.id}/schedules", params: { send_at: Time.zone.parse(send_at).to_i })
  end

  def send
    self.class.call(path: "campaigns/#{self.id}/schedules/now")
  end

  def unschedule
    self.class.call(method: :delete, path: "campaigns/#{self.id}/schedules")
  end

  def delete
    self.class.call(method: :delete, path: "campaigns/#{self.id}")
  end
end
