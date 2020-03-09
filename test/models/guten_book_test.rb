require 'test_helper'

class GutenBookTest < ActiveSupport::TestCase
  test "contents" do
    book = GutenBook.new(id: 8)
    assert_equal 2, book.contents.length
  end
end
