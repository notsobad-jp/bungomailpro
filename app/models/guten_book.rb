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


  def count_words
    return if (text = self.text).nil?
    words_count = text.delete("\r\n").scan(/[\w.\/:;'-]+/).length
    self.update(
      words_count: words_count,
      chars_count: text.gsub(/\s/, "").length
    )
    p "Counted [#{id}] #{title}"
  rescue => e
    p e
  end

  def text
    url = "http://www.gutenberg.org/cache/epub/#{id}/pg#{id}.txt"
    file = open(url)
    splited_text = file.read.split(/\*\*\*\s?(START|END) OF (THIS|THE) PROJECT GUTENBERG EBOOK [^*]+\s?\*\*\*/)
    return if splited_text.size != 7
    splited_text[3].strip
  rescue => e
    p e
    nil
  end

  def set_feeds(user_id)
    feeds = []
    contents = self.split_text
    send_at = Time.zone.tomorrow

    contents.each.with_index(1) do |content, index|
      title = "#{self.title}（#{index}/#{contents.count}）"
      feeds << Feed.new(
        guten_book_id: self.id,
        user_id: user_id,
        index: index,
        title: title,
        content: content,
        send_at: send_at
      )
      send_at += 1.day
    end
    Feed.import feeds
  end

  def split_text(words_per: 500)
    sentences = self.text.gsub(/([\r\n]+)/, '\1[[TMP]]').gsub(". ", ".[[TMP]]").split("[[TMP]]")

    contents = [""]
    contents_index = 0
    word_count = 0

    sentences.each do |sentence|
      contents[contents_index] += sentence
      word_count += sentence.word_count

      if word_count > words_per
        contents_index += 1
        word_count = 0
        contents[contents_index] = ""  # TODO:次の配信の最初に、前回の最後の一文を追加
      end
    end

    # 最後が短すぎるときは、一つ前のにマージして最終回を削除
    if contents.last.word_count < 200
      contents[-2] += contents[-1]
      contents.pop
    end

    contents
  end


  class << self
    def pick
      ids = ActiveRecord::Base.connection.select_values("select guten_book_id from guten_books_subjects where subject_id IN (select id from subjects where LOWER(id) LIKE '%fiction%')")
      self.where(id: ids, language: 'en', rights: 'Public domain in the USA.', words_count: 3000..30000).where("downloads > ?", 30).order(Arel.sql("RANDOM()")).first
    end

    def import_rdf(id)
      file_path = "tmp/gutenberg/#{id}/pg#{id}.rdf"
      xml = File.open(file_path, &:read)

      charset = 'UTF-8'
      doc = Nokogiri::XML.parse(xml, nil, charset)
      title = doc.xpath('//dcterms:title').first.try(:text)
      author = doc.xpath('//dcterms:creator/pgterms:agent/pgterms:name').first.try(:text)
      rights = doc.xpath('//dcterms:rights').first.try(:text)
      language = doc.xpath('//dcterms:language/rdf:Description/rdf:value').first.try(:text)
      downloads = doc.xpath('//pgterms:downloads').first.try(:text)
      subject_names = doc.xpath('//dcterms:subject/rdf:Description/rdf:value').map{|value| value.text.split('--').map(&:strip) }.flatten.uniq

      subjects = []
      subject_names.each do |name|
        subjects <<  Subject.find_or_initialize_by(id: name)
      end

      book = GutenBook.find_or_initialize_by(id: id)
      book.update(
        title: title,
        author: author,
        rights: rights,
        language: language,
        downloads: downloads,
        subjects: subjects,
      )
      p "Imported: [#{id}] #{title}"
    rescue => e
      p e
    end
  end
end
