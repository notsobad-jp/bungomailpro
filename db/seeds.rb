# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = User.create(email: 'info@notsobad.jp', timezone: 'Tokyo', locale: 'ja')
Channel.create(
  id: "4c386a3c-ed38-4e6e-8505-334a6e9f5043",
  user_id: admin.id,
  title: 'BungoMail Official Channel',
  description: '',
  public: true,
)
Channel.create(
  id: "821b9354-8ce4-4706-8fdc-6ac42c16e053",
  user_id: admin.id,
  title: 'ブンゴウメール公式チャネル',
  description: '',
  public: true,
)
