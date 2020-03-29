require 'test_helper'

class GutenBookTest < ActiveSupport::TestCase
  test "contents" do
    assert_equal 2, guten_books(8).contents.length
  end

  test "first_sentence" do
    assert_equal "The oldest etext known to Project Gutenberg (ca. 1964-1965) (If you know of any older ones, please let us know.)", guten_books(26).first_sentence
  end
end
