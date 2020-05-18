require 'rails_helper'

RSpec.describe String, type: :model do
  describe "words" do
    it "should count words" do
      text = <<-EOS
        Mr. Who talked to me. I was in the U.S.A. at that time.
        I said
        that I can not believe it! Why? Mr. Who asked.
        "I don't know." I answered.
      EOS
      expect(text.words.count).to eq(30)
    end
  end

  describe "sentences" do
    it "should count sentences" do
      # Mr.などの特殊ピリオド除外。改行・空白を伴うピリオドで区分。会話文で "が続くときも区切る。!?でも区切る。
      text = <<-EOS
        Mr. Who talked to me. I was in the U.S.A. at that time.
        I said
        that I can not believe it! Why? Mr. J. J. Bean asked.
        "I don't know." I answered.
      EOS
      expect(text.sentences.count).to eq(7)
    end

    it "should divide sentence with ca without preceding space" do
      text = "I like Jamaica. Mr. A said."
      expect(text.sentences.count).to eq(2)
    end

    it "should not divide sentence with ca with preceding bracket" do
      text = "This era(ca. 1900 - 2000) is old."
      expect(text.sentences.count).to eq(1)
    end

    it "should not divide sentence with one character + period" do
      text = "J. J. Bean died."
      expect(text.sentences.count).to eq(1)
    end

    it "should not divide sentence with period following bracket" do
      text = "I know (If you know it, please let us know.) Introduction ends."
      expect(text.sentences.count).to eq(1)
    end

    it "should not divide sentence with period preceding month" do
      text = "St. Petersburgh, DEC. 11th, 17—."
      expect(text.sentences.count).to eq(1)
    end
  end
end
