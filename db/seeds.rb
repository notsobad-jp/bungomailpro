# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

categories = [
  {
    id: 'flash',
    name: '5分以内',
    range_from: 1,
    range_to: 2000
  },
  {
    id: 'shortshort',
    name: '10分以内',
    range_from: 2000,
    range_to: 4000
  },
  {
    id: 'short',
    name: '30分以内',
    range_from: 4000,
    range_to: 12000
  },
  {
    id: 'novelette',
    name: '60分以内',
    range_from: 12000,
    range_to: 24000
  },
  {
    id: 'novel',
    name: '1時間〜',
    range_from: 24000,
    range_to: 9999999,
  },
  {
    id: 'all',
    name: 'すべての作品',
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
