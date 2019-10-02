module Zorapi
  AOZORA_BASE_URL = 'https://www.aozora.gr.jp/'
  API_BASE_URL = 'https://api.github.com/search/code'

  def self.call(q)
    uri = URI.parse(API_BASE_URL + "?q=#{q}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Get.new(uri.request_uri)
    req["Accept"] = 'application/vnd.github.v3.text-match+json'
    req["content-type"] = 'application/json'

    JSON.parse(http.request(req).body)
  end

  def self.Author(id)
    Author.new(id)
  end

  def self.Book(id)
    Book.new(id)
  end


  class Author
    attr_accessor :id

    def initialize(id)
      @id = id
    end

    def self.search(query)
      q = "#{CGI.escape(query + "</a>")}+in:file+repo:aozorabunko/aozorabunko+path:index_pages+filename:person_all+extension:html+-filename:inp"
      res = parent.call(q)

      text_matches = res["items"].map{|item| item["text_matches"].find{ |k| k["matches"].to_s.include? query } }.compact
      authors = []
      text_matches.each do |t|
        match = /person(\d+)\.html">(.*#{query}.*?)<\/a>/.match(t["fragment"])
        byebug
        authors << {
          id: match[1].to_i,
          name: match[2],
          url: File.join(AOZORA_BASE_URL, "index_pages", "person#{match[1]}.html")
        } if match
      end
      authors.uniq
    end

    def books
      # author_id = self.id.to_s.rjust(6, "0")
      query = "メロスは激怒した"
      author_id = nil

      # q = "repo:aozorabunko/aozorabunko+path:cards/#{author_id}/files+extension:html+filename:card"
      q = "#{CGI.escape(query)}+in:file+repo:aozorabunko/aozorabunko+path:cards#{ ("/" + author_id + "/files") if author_id }+extension:html+-filename:card"
      res = self.class.parent.call(q)
      byebug
    end
  end


  class Book
    attr_accessor :id

    def initialize(id)
      @id = id
    end

    def self.search(query, author_id=nil)
      q = "#{CGI.escape('<meta name="DC.Title" content=' + query)}+in:file+repo:aozorabunko/aozorabunko+path:cards#{ ("/" + author_id + "/files") if author_id }+extension:html+-filename:card"
      res = parent.call(q)

      text_matches = res["items"].map{|item| item["text_matches"].find{ |k| k["matches"].to_s.include? query } }.compact
      match = /cards\/(\d+)\/files\/(\d+_\d+)\.html/.match(text_matches[0]["object_url"])

      {
        author_id: match[1].to_i,
        book_id: match[2].split("_")[0].to_i,
        url: File.join(AOZORA_BASE_URL, "cards", match[1], "files", "#{match[2]}.html")
      }
    end
  end
end
