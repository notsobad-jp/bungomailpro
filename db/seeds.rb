# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'

User.create(email: 'info@notsobad.jp', trial_end_at: '2000-01-01 00:00:00')

senders = File.open("db/seeds/senders.json", &:read)
JSON.parse(senders).each do |sender|
  Sender.create(
    id: sender["id"],
    nickname: sender["nickname"],
    name: sender["from"]["name"],
  )
end

groups = []
CSV.foreach('db/seeds/campaign_groups.csv', headers: true) do |data|
  groups << CampaignGroup.new(
    book_id: data["ID"],
    count: data["回数"],
    start_at: Time.zone.parse(data["開始日"]),
    list_id: CampaignGroup::LIST_ID,
    sender_id: 611140,
  )
end
CampaignGroup.import groups
