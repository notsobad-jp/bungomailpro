# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(email: 'info@notsobad.jp')

senders = File.open("db/seeds/senders.json", &:read)
JSON.parse(senders).each do |sender|
  Sender.create(
    id: sender["id"],
    nickname: sender["nickname"],
    name: sender["from"]["name"],
  )
end
