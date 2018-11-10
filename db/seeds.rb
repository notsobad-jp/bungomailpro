# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create( email: ENV['MAILER_EMAIL'] )

urls = [
  'https://www.aozora.gr.jp/cards/001155/files/43644_29257.html',
  'https://www.aozora.gr.jp/cards/001155/files/51860_41507.html'
]
urls.each do |url|
  params = Book.parse_html(url)
  Book.create(params)
end


course = Course.new(
  title: 'チェーホフ完読コース',
  description: '青空文庫で公開されているチェーホフの全作品を読破できるコースです。おもしろいよ！',
  owner_id: 1
)
Book.all.each.with_index(1) do |book, index|
  course.course_books.build(
    book_id: book.id,
    index: index
  )
end
course.save!
