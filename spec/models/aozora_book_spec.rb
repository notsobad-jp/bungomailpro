require 'rails_helper'

RSpec.describe AozoraBook, type: :model do
  ####################################################
  # author_name
  ####################################################
  describe 'author_name' do
    context 'when single author, Japanese name' do
      let(:name) { '芥川 竜之介' }
      it "should return author name without space" do
        expect(AozoraBook.author_name(name)).to eq('芥川竜之介')
      end
    end

    context 'when single author, English name' do
      let(:name) { 'アンデルセン ハンス・クリスチャン' }
      it "should return author name in revese order" do
        expect(AozoraBook.author_name(name)).to eq('ハンス・クリスチャン・アンデルセン')
      end
    end

    context 'when multiple author, Japanese name' do
      let(:name) { '黒木 舜平, 太宰 治' }
      it "should return first author name without space" do
        expect(AozoraBook.author_name(name)).to eq('黒木舜平')
      end
    end

    context 'when single author, English name' do
      let(:name) { 'ワイルド オスカー, 渡辺 温' }
      it "should return first author name in revese order" do
        expect(AozoraBook.author_name(name)).to eq('オスカー・ワイルド')
      end
    end
  end

  ####################################################
  # author_search_name
  ####################################################
  describe 'author_search_name' do
    context 'when single author, Japanese name' do
      let(:name) { '芥川竜之介' }
      it "should return author name without space" do
        expect(AozoraBook.author_search_name(name)).to eq('芥川竜之介')
      end
    end

    context 'when single author, English name' do
      let(:name) { 'ハンス・クリスチャン・アンデルセン' }
      it "should return author name in revese order" do
        expect(AozoraBook.author_search_name(name)).to eq('アンデルセンハンス・クリスチャン')
      end
    end
  end
end
