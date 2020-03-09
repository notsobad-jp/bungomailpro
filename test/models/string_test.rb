require 'test_helper'

class StringTest < ActiveSupport::TestCase
  test "words" do
    text = <<-EOS
      Mr. Who talked to me. I was in the U.S.A. at that time.
      I said
      that I can not believe it! Why? Mr. Who asked.
      "I don't know." I answered.
    EOS
    assert_equal 30, text.words.count
  end

  test "sentences" do
    # Mr.などの特殊ピリオド除外。改行・空白を伴うピリオドで区分。会話文で "が続くときも区切る。!?でも区切る。
    text = <<-EOS
      Mr. Who talked to me. I was in the U.S.A. at that time.
      I said
      that I can not believe it! Why? Mr.Who asked.
      "I don't know." I answered.
    EOS
    assert_equal 7, text.sentences.count
  end
end
