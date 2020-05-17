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
end
