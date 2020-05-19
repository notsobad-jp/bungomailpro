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

    context 'when id is 1342', test: true do
      let(:guten_book) { GutenBook.find(1342) }
      it "should return correct first sentence" do
        expect(subject).to eq("Chapter 1   It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife.")
      end
    end

    # 製作年が入っちゃうけどしょうがない。。。
    context 'when id is 1080' do
      let(:guten_book) { GutenBook.find(1080) }
      it "should return correct first sentence" do
        expect(subject).to eq("1729    It is a melancholy object to those, who walk through this great town, or travel in the country, when they see the streets, the roads and cabbin-doors crowded with beggars of the female sex, followed by three, four, or six children, all in rags, and importuning every passenger for an alms.")
      end
    end

    context 'when id is 84' do
      let(:guten_book) { GutenBook.find(84) }
      it "should return correct first sentence" do
        expect(subject).to eq("Letter 1   St. Petersburgh, Dec. 11th, 17--  TO Mrs. Saville, England  You will rejoice to hear that no disaster has accompanied the commencement of an enterprise which you have regarded with such evil forebodings.")
      end
    end

    # TODO: 見出しばっかりなのでうまく取れない
    context 'when id is 25525' do
      let(:guten_book) { GutenBook.find(25525) }
      xit "should return correct first sentence" do
        expect(subject).to eq("The Works of Edgar Allan Poe, Contents and Index of Five Volumes   THE WORKS OF EDGAR ALLAN POE  TABLE OF CONTENTS AND INDEX OF THE FIVE VOLUMES  The Raven Edition   Project Gutenberg Volumes: #2147, #2148, #2149, #2150, #2151    CONTENTS  INDEX    CONTENTS  VOLUME 1  EDGAR ALLAN POE  DEATH OF EDGAR A. POE  THE UNPARALLELED ADVENTURES OF ONE HANS PFAAL  THE GOLD-BUG  FOUR BEASTS IN ONE&mdash;THE HOMO-CAMELEOPARD  THE MURDERS IN THE RUE MORGUE  THE MYSTERY OF MARIE ROGET  THE BALLOON-HOAX  MS. FOUND IN A BOTTLE  THE OVAL PORTRAIT  VOLUME 2  THE PURLOINED LETTER  THE THOUSAND-AND-SECOND TALE OF SCHEHERAZADE  A DESCENT INTO THE MAELSTROM.")
      end
    end

    # うまく取れてないけどしょうがない。。。
    context 'when id is 2701' do
      let(:guten_book) { GutenBook.find(2701) }
      it "should return correct first sentence" do
        expect(subject).to eq("Original Transcriber's Notes:  This text is a combination of etexts, one from the now-defunct ERIS project at Virginia Tech and one from Project Gutenberg's archives.")
      end
    end

    context 'when id is 43' do
      let(:guten_book) { GutenBook.find(43) }
      it "should return correct first sentence" do
        expect(subject).to eq("STORY OF THE DOOR   Mr. Utterson the lawyer was a man of a rugged countenance that was never lighted by a smile; cold, scanty and embarrassed in discourse; backward in sentiment; lean, long, dusty, dreary and yet somehow lovable.")
      end
    end

    context 'when id is 98' do
      let(:guten_book) { GutenBook.find(98) }
      it "should return correct first sentence" do
        expect(subject).to eq("Book the First--Recalled to Life     I. The Period   It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness, it was the epoch of belief, it was the epoch of incredulity, it was the season of Light, it was the season of Darkness, it was the spring of hope, it was the winter of despair, we had everything before us, we had nothing before us, we were all going direct to Heaven, we were all going direct the other way-- in short, the period was so far like the present period, that some of its noisiest authorities insisted on its being received, for good or for evil, in the superlative degree of comparison only.")
      end
    end

    context 'when id is 2542' do
      let(:guten_book) { GutenBook.find(2542) }
      it "should return correct first sentence" do
        expect(subject).to eq("DRAMATIS PERSONAE       Torvald Helmer.")
      end
    end

    context 'when id is 1661' do
      let(:guten_book) { GutenBook.find(1661) }
      it "should return correct first sentence" do
        expect(subject).to eq("ADVENTURE I. A SCANDAL IN BOHEMIA  I.  To Sherlock Holmes she is always THE woman.")
      end
    end

    context 'when id is 345' do
      let(:guten_book) { GutenBook.find(345) }
      it "should return correct first sentence" do
        expect(subject).to eq("CHAPTER I  JONATHAN HARKER'S JOURNAL  (_Kept in shorthand._)   _3 May. Bistritz._--Left Munich at 8:35 P. M., on 1st May, arriving at Vienna early next morning; should have arrived at 6:46, but train was an hour late.")
      end
    end

    context 'when id is 11' do
      let(:guten_book) { GutenBook.find(11) }
      it "should return correct first sentence" do
        expect(subject).to eq("CHAPTER I. Down the Rabbit-Hole  Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, 'and what is the use of a book,' thought Alice 'without pictures or conversations?'")
      end
    end

    context 'when id is 1952' do
      let(:guten_book) { GutenBook.find(1952) }
      it "should return correct first sentence" do
        expect(subject).to eq("It is very seldom that mere ordinary people like John and myself secure ancestral halls for the summer.")
      end
    end

    context 'when id is 46' do
      let(:guten_book) { GutenBook.find(46) }
      it "should return correct first sentence" do
        expect(subject).to eq("PREFACE  I HAVE endeavoured in this Ghostly little book, to raise the Ghost of an Idea, which shall not put my readers out of humour with themselves, with each other, with the season, or with me.")
      end
    end

    # いまいちだけどしょうがない
    context 'when id is 6130' do
      let(:guten_book) { GutenBook.find(6130) }
      it "should return correct first sentence" do
        expect(subject).to eq("The Iliad of Homer   Translated by Alexander Pope,  with notes by the Rev.")
      end
    end

    context 'when id is 41' do
      let(:guten_book) { GutenBook.find(41) }
      it "should return correct first sentence" do
        expect(subject).to eq("A pleasing land of drowsy head it was,           Of dreams that wave before the half-shut eye;         And of gay castles in the clouds that pass,           Forever flushing round a summer sky.")
      end
    end

    # いまいちだけどしょうがない
    context 'when id is 25344' do
      let(:guten_book) { GutenBook.find(25344) }
      it "should return correct first sentence" do
        expect(subject).to eq("[Illustration]                             LIST OF ILLUSTRATIONS.")
      end
    end

    # いまいちだけどしょうがない
    context 'when id is 205' do
      let(:guten_book) { GutenBook.find(205) }
      it "should return correct first sentence" do
        expect(subject).to eq("Contents   =WALDEN=  Economy  Where I Lived, and What I Lived For  Reading  Sounds  Solitude  Visitors  The Bean-Field  The Village  The Ponds  Baker Farm  Higher Laws  Brute Neighbors  House-Warming  Former Inhabitants and Winter Visitors  Winter Animals  The Pond in Winter  Spring  Conclusion   =ON THE DUTY OF CIVIL DISOBEDIENCE=     WALDEN     Economy   When I wrote the following pages, or rather the bulk of them, I lived alone, in the woods, a mile from any neighbor, in a house which I had built myself, on the shore of Walden Pond, in Concord, Massachusetts, and earned my living by the labor of my hands only.")
      end
    end

    context 'when id is 219' do
      let(:guten_book) { GutenBook.find(219) }
      it "should return correct first sentence" do
        expect(subject).to eq("I   The Nellie, a cruising yawl, swung to her anchor without a flutter of the sails, and was at rest.")
      end
    end
  end
end
