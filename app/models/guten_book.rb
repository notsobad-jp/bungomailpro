# == Schema Information
#
# Table name: guten_books
#
#  id          :bigint(8)        not null, primary key
#  author      :string           not null
#  downloads   :bigint(8)
#  language    :string
#  rights      :string
#  title       :string           not null
#  words_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class GutenBook < ApplicationRecord
  has_and_belongs_to_many :subjects

  def self.import_rdf(id)
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
