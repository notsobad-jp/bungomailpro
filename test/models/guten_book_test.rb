require 'test_helper'

class GutenBookTest < ActiveSupport::TestCase
  test "contents" do
    assert_equal 2, guten_books(8).contents.length
  end

  test "first_sentence" do
    sentence = guten_books(26).first_sentence
    assert_equal "Book I   Of Man's first disobedience, and the fruit Of that forbidden tree whose mortal taste Brought death into the World, and all our woe, With loss of Eden, till one greater Man Restore us, and regain the blissful seat, Sing, Heavenly Muse, that, on the secret top Of Oreb, or of Sinai, didst inspire That shepherd who first taught the chosen seed In the beginning how the heavens and earth Rose out of Chaos: or, if Sion hill Delight thee more, and Siloa's brook that flowed Fast by the oracle of God, I thence Invoke thy aid to my adventurous song, That with no middle flight intends to soar Above th' Aonian mount, while it pursues Things unattempted yet in prose or rhyme.", sentence

    sentence = guten_books(1661).first_sentence
    assert_equal "I. A Scandal in Bohemia   II. The Red-headed League  III. A Case of Identity   IV. The Boscombe Valley Mystery    V. The Five Orange Pips   VI. The Man with the Twisted Lip  VII. The Adventure of the Blue Carbuncle VIII. The Adventure of the Speckled Band   IX. The Adventure of the Engineer's Thumb    X. The Adventure of the Noble Bachelor   XI. The Adventure of the Beryl Coronet  XII. The Adventure of the Copper Beeches     ADVENTURE I. A SCANDAL IN BOHEMIA  I.  To Sherlock Holmes she is always THE woman.", sentence

    sentence = guten_books(345).first_sentence
    assert_equal "CHAPTER I  JONATHAN HARKER'S JOURNAL  (_Kept in shorthand._)   _3 May.", sentence
  end
end
