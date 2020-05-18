require 'rails_helper'

RSpec.describe GutenBook, type: :model do
  ####################################################
  # author_name
  ####################################################
  describe 'author_name' do
    context 'when single author, one connma' do
      let(:name) { 'Melville, Herman' }
      it "should return author name with space" do
        expect(GutenBook.author_name(name)).to eq('Herman Melville')
      end
    end

    context 'when single author, one connma and three words' do
      let(:name) { 'Longfellow, Henry Wadsworth' }
      it "should return author name with space" do
        expect(GutenBook.author_name(name)).to eq('Henry Wadsworth Longfellow')
      end
    end

    context 'when single author, no connma' do
      let(:name) { 'United States. Central Intelligence Agency' }
      it "should return author name as it is" do
        expect(GutenBook.author_name(name)).to eq('United States. Central Intelligence Agency')
      end
    end

    context 'when multiple authors' do
      let(:name) { 'Orczy, Emmuska Orczy, Baroness' }
      it "should return author name as it is" do
        expect(GutenBook.author_name(name)).to eq('Orczy, Emmuska Orczy, Baroness')
      end
    end
  end

  ####################################################
  # author_search_name
  ####################################################
  describe 'author_search_name' do
    context 'when single author, one connma' do
      let(:name) { 'Herman Melville' }
      it "should return author name with space" do
        expect(GutenBook.author_search_name(name)).to eq('Melville,Herman')
      end
    end

    context 'when single author, one connma and three words' do
      let(:name) { 'Henry Wadsworth Longfellow' }
      it "should return author name with space" do
        expect(GutenBook.author_search_name(name)).to eq('Longfellow,HenryWadsworth')
      end
    end

    # TODO: 著者名正規化して対応
    context 'when single author, no connma' do
      let(:name) { 'United States. Central Intelligence Agency' }
      xit "should return author name as it is" do
        expect(GutenBook.author_search_name(name)).to eq('United States. Central Intelligence Agency')
      end
    end

    # TODO: 著者名正規化して対応
    context 'when multiple authors' do
      let(:name) { 'Orczy, Emmuska Orczy, Baroness' }
      xit "should return author name as it is" do
        expect(GutenBook.author_search_name(name)).to eq('Orczy, Emmuska Orczy, Baroness')
      end
    end
  end

  ####################################################
  # First Sentence
  ####################################################
  describe 'first_sentence' do
    subject { guten_book.first_sentence }

    context 'when id is 26' do
      let(:guten_book) { GutenBook.find(26) }
      it "should return correct first sentence" do
        expect(subject).to eq("Book I   Of Man's first disobedience, and the fruit Of that forbidden tree whose mortal taste Brought death into the World, and all our woe, With loss of Eden, till one greater Man Restore us, and regain the blissful seat, Sing, Heavenly Muse, that, on the secret top Of Oreb, or of Sinai, didst inspire That shepherd who first taught the chosen seed In the beginning how the heavens and earth Rose out of Chaos: or, if Sion hill Delight thee more, and Siloa's brook that flowed Fast by the oracle of God, I thence Invoke thy aid to my adventurous song, That with no middle flight intends to soar Above th' Aonian mount, while it pursues Things unattempted yet in prose or rhyme.")
      end
    end

    context 'when id is 1661' do
      let(:guten_book) { GutenBook.find(1661) }
      it "should return correct first sentence" do
        expect(subject).to eq("I. A Scandal in Bohemia   II. The Red-headed League  III. A Case of Identity   IV. The Boscombe Valley Mystery    V. The Five Orange Pips   VI. The Man with the Twisted Lip  VII. The Adventure of the Blue Carbuncle VIII. The Adventure of the Speckled Band   IX. The Adventure of the Engineer's Thumb    X. The Adventure of the Noble Bachelor   XI. The Adventure of the Beryl Coronet  XII. The Adventure of the Copper Beeches     ADVENTURE I. A SCANDAL IN BOHEMIA  I.  To Sherlock Holmes she is always THE woman.")
      end
    end

    context 'when id is 345' do
      let(:guten_book) { GutenBook.find(345) }
      it "should return correct first sentence" do
        expect(subject).to eq("CHAPTER I  JONATHAN HARKER'S JOURNAL  (_Kept in shorthand._)   _3 May.")
      end
    end
  end
end
