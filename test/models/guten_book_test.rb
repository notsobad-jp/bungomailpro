require 'test_helper'

class GutenBookTest < ActiveSupport::TestCase
  setup do
    file_path = "test/fixtures/files/pg8.txt.utf8.gzip"
    book_text = Zlib::GzipReader.new(open(file_path)).read
    stub_request(:get, "https://www.gutenberg.org/cache/epub/8/pg8.txt").
      with(
        headers: {
    	  'Accept'=>'*/*',
    	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    	  'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: book_text, headers: {})
  end

  test "contents" do
    book = GutenBook.new(id: 8)
    assert_equal 2, book.contents.length
  end
end
