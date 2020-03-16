# == Schema Information
#
# Table name: guten_books
#
#  id          :bigint(8)        not null, primary key
#  author      :string           not null
#  chars_count :integer          default(0), not null
#  downloads   :bigint(8)
#  language    :string
#  rights      :string
#  title       :string           not null
#  words_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'open-uri'

class GutenBook < ApplicationRecord
  has_and_belongs_to_many :subjects

  scope :sorted, -> { order(downloads: :desc) }

  # アクセス数に対する評価(download数)
  ## ratingは JSON-LDで表示するメタ評価
  ## starsはサイト上で表示する星の数
  ACCESS_RATINGS = {
    50 => { rating: 5,   stars: 3 },
    15 =>   { rating: 4.5, stars: 2 },
    1 =>     { rating: 4,   stars: 1 },
    0 =>     { rating: 3,   stars: 0 }
  }.freeze

  WORDS_PER_MINUTES = 500
  CATEGORIES = {
    all: {
      id: 'all',
      name: 'all',
      range_from: 1,
      range_to: 9999999,
      books_count: 42446
    },
    flash: {
      id: 'flash',
      name: '5min',
      title: 'flash',
      range_from: 1,
      range_to: WORDS_PER_MINUTES * 5,
      books_count: 1038
    },
    shortshort: {
      id: 'shortshort',
      name: '10min',
      title: 'shortshort',
      range_from: WORDS_PER_MINUTES * 5 + 1,
      range_to: WORDS_PER_MINUTES * 10,
      books_count: 1653
    },
    short: {
      id: 'short',
      name: '30min',
      title: 'short',
      range_from: WORDS_PER_MINUTES * 10 + 1,
      range_to: WORDS_PER_MINUTES * 30,
      books_count: 6401
    },
    novelette: {
      id: 'novelette',
      name: '60min',
      title: 'novelette',
      range_from: WORDS_PER_MINUTES * 30 + 1,
      range_to: WORDS_PER_MINUTES * 60,
      books_count: 6831
    },
    novel: {
      id: 'novel',
      name: 'over 1h',
      title: 'novel',
      range_from: WORDS_PER_MINUTES * 60 + 1,
      range_to: 9999999,
      books_count: 26523
    }
  }.freeze


  def access_rating(type = :rating)
    ACCESS_RATINGS.find{|k,v| self.downloads >= k }.dig(1, type)
  end

  # TODO:
  def beginning
    ""
  end

  def gutenberg_book_url
    "https://www.gutenberg.org/ebooks/#{id}"
  end

  def gutenberg_text_url
    "https://www.gutenberg.org/cache/epub/#{id}/pg#{id}.txt"
  end

  # 加工前のテキストファイル。本番はGutenbergから、それ以外ではローカルのtmpファイルから返す
  def raw_text
    local_file = "tmp/gutenberg/text/#{id}/pg#{id}.txt.utf8.gzip"
    if File.exist?(local_file)
      Zlib::GzipReader.new(open(local_file)).read
    else
      open(gutenberg_text_url).read
    end
  end

  # 不要な部分を除去したテキストファイル本文
  def text
    splited_text = raw_text.split(/\*\*\*\s?(START|END) OF (THIS|THE) PROJECT GUTENBERG EBOOK [^*]+\s?\*\*\*/)
    return if splited_text.size != 7
    splited_text[3].strip
  rescue => e
    p e
    nil
  end

  # 各回が指定文字数でいい感じに配信されるように分割する
  def contents(words_per: 400)
    # センテンスに分割（Stringクラス拡張）
    sentences = self.text.sentences

    contents = [""]
    contents_index = 0
    word_count = 0
    last_sentences = []

    sentences.each do |sentence|
      contents[contents_index] += sentence
      word_count += sentence.words.length

      # 文字数が設定を超えたら次に回す（最後の回はここを通ったり通らなかったりする）
      if word_count > words_per
        contents_index += 1
        word_count = 0
        contents[contents_index] = ""
        last_sentences << sentence.sub(/(\r\n|\r|\n)/," ") # 前回最後の一文を配列に保存しておく（最初の改行文字はずれることが多いのでスペースに置き換え）
      end
    end

    # 最後が短すぎるときは、一つ前のにマージして最終回を削除
    if contents.last.words.length < 200
      contents[-2] += contents[-1]
      contents.pop
    end

    # 各回最後の一文を次回の冒頭に追加
    contents.each_with_index do |content, index|
      next if index == 0
      last_sentence = last_sentences[index - 1]
      last_sentence = '…' + last_sentence.slice(-150..-1) if last_sentence.length > 150
      contents[index] = last_sentence + content
    end

    contents
  end

  def category
    CATEGORIES.dig(self.category_id&.to_sym)
  end

  def popularity
    self.downloads
  end

  # Gutenbergはファイル直リンクを禁止してるので、 詳細ページに飛ばす
  def original_file_url
    self.gutenberg_book_url
  end


  class << self
    def import_rdf(id)
      file_path = "tmp/gutenberg/rdf/#{id}/pg#{id}.rdf"
      xml = File.open(file_path, &:read)

      charset = 'UTF-8'
      doc = Nokogiri::XML.parse(xml, nil, charset)
      title = doc.xpath('//dcterms:title').first.try(:text)
      author = doc.xpath('//dcterms:creator/pgterms:agent/pgterms:name').first.try(:text)
      author_id = doc.xpath('//dcterms:creator/pgterms:agent').first&.attributes&.dig("about")&.value&.split("/")&.last
      rights = doc.xpath('//dcterms:rights').first.try(:text)
      language = doc.xpath('//dcterms:language/rdf:Description/rdf:value').first.try(:text)
      downloads = doc.xpath('//pgterms:downloads').first.try(:text)
      subject_names = doc.xpath('//dcterms:subject/rdf:Description/rdf:value').map{|value| value.text.split('--').map(&:strip) }.flatten.uniq

      subjects = []
      subject_names.each do |name|
        subjects <<  Subject.find_or_initialize_by(id: name)
      end

      return unless title
      book = GutenBook.find_or_initialize_by(id: id)
      book.update(
        title: title,
        author: author,
        author_id: author_id,
        rights_reserved: rights != 'Public domain in the USA.',
        language: language,
        downloads: downloads,
        subjects: subjects,
      )
      p "Imported: [#{id}] #{title}"
    rescue => e
      p e
    end

    def popular_authors
      self.limit(100).where.not(author: nil).order('sum_downloads desc').group(:author, :author_id).sum(:downloads)
    end
  end
end
