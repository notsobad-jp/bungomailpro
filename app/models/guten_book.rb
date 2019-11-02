# == Schema Information
#
# Table name: guten_books
#
#  id          :bigint(8)        not null, primary key
#  author      :string           not null
#  language    :string
#  rights      :string
#  title       :string           not null
#  words_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  file_id     :bigint(8)
#

class GutenBook < ApplicationRecord
  def self.import_from_rdf
    id = 1
    file_path = "tmp/gutenberg/#{id}/pg#{id}.rdf"
    xml = File.open(file_path, &:read)

    charset = 'UTF-8'
    doc = Nokogiri::XML.parse(xml, nil, charset)
    title = doc.xpath('//dcterms:title').first.try(:text)
    author = doc.xpath('//dcterms:creator/pgterms:agent/pgterms:name').first.try(:text)
    rights = doc.xpath('//dcterms:rights').first.try(:text)
    language = doc.xpath('//dcterms:language/rdf:Description/rdf:value').first.try(:text)

    GutenBook.create(
      id: id,
      title: title,
      author: author,
      rights: rights,
      language: language
    )
  end
end
