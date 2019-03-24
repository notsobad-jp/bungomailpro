# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# books = [
#   "https://www.aozora.gr.jp/cards/000081/card45630.html", #宮沢賢治：雨ニモマケズ
#   "https://www.aozora.gr.jp/cards/000148/card789.html", #夏目漱石：吾輩は猫である
#   "https://www.aozora.gr.jp/cards/000879/card127.html", #芥川龍之介；羅生門
#   "https://www.aozora.gr.jp/cards/000035/card301.html", #太宰治；人間失格
# ]
# books.each do |url|
#   Book.create_from_aozora_card(url)
# end


categories = [
  {
    id: 'flash',
    name: '掌編',
    range_from: 0,
    range_to: 1000
  },
  {
    id: 'shortshort',
    name: 'ショートショート',
    range_from: 1000,
    range_to: 5000
  },
  {
    id: 'short',
    name: '短編',
    range_from: 5000,
    range_to: 15000
  },
  {
    id: 'novelette',
    name: '中編',
    range_from: 15000,
    range_to: 30000
  },
  {
    id: 'novel',
    name: '長編',
    range_from: 30000,
    range_to: 9999999,
  },
  {
    id: 'all',
    name: 'すべて',
    range_from: 0,
    range_to: 9999999,
  }
]
categories.each do |category|
  Category.create(
    id: category[:id],
    name: category[:name],
    range_from: category[:range_from],
    range_to: category[:range_to],
  )
end
