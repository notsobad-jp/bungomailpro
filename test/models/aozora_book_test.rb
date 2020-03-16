require 'test_helper'

class AozoraBookTest < ActiveSupport::TestCase
  test "access_rating: 1000" do
    book = AozoraBook.new(access_count: 10000)
    assert_equal 5, book.access_rating
    assert_equal 3, book.access_rating(:stars)
  end

  test "access_rating: 500" do
    book = AozoraBook.new(access_count: 500)
    assert_equal 4.5, book.access_rating
    assert_equal 2, book.access_rating(:stars)
  end

  test "access_rating: 1" do
    book = AozoraBook.new(access_count: 1)
    assert_equal 4, book.access_rating
    assert_equal 1, book.access_rating(:stars)
  end

  test "access_rating: 0" do
    book = AozoraBook.new(access_count: 0)
    assert_equal 3, book.access_rating
    assert_equal 0, book.access_rating(:stars)
  end
end
