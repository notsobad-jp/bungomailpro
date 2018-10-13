# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

course = Course.create(
  title: 'チェーホフ完読コース',
  description: '青空文庫で公開されているチェーホフの全作品を読破できるコースです。おもしろいよ！'
)


book1 = Book.create(
  aozora_id: 51860,
  title: 'かもめ',
  author: 'チェーホフ'
)
book1.chapters.create([
  { index: 1, text: 'かもめのテキスト1' },
  { index: 2, text: 'かもめのテキスト2' },
  { index: 3, text: 'かもめのテキスト3' },
  { index: 4, text: 'かもめのテキスト4' },
  { index: 5, text: 'かもめのテキスト5' }
])
book2 = Book.create(
  aozora_id: 51862,
  title: 'ワーニャおじさん',
  author: 'チェーホフ'
)
book2.chapters.create([
  { index: 1, text: 'おじさんのテキスト1' },
  { index: 2, text: 'おじさんのテキスト2' },
  { index: 3, text: 'おじさんのテキスト3' }
])


course.course_books.create([
  { book_id: 1, index: 2 },
  { book_id: 2, index: 1 }
])


User.create(
  email: ENV['MAILER_EMAIL']
)
