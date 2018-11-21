# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create( email: ENV['MAILER_EMAIL'] )

book_ids = [
  [1155,43644],
  [1155,51860],
  [1095,45735],
  [1095,43147],
  [1235,49866],
  [1235,49867],
  [1235,49865],
  [1235,49861],
  [1235,53047],
  [1235,49862],
  [1235,49860],
  [1235,49859],
  [1235,49858],
  [1235,49864],
  [96,2093],
  [1403,49986],
  [119,24439],
  [119,621],
  [119,1737],
  [119,42301],
  [119,24443],
  [119,2521],
  [879,43016],
  [879,43015],
  [879,60],
  [879,140],
  [879,3814],
  [879,19],
  [879,55],
  [879,42],
  [879,179],
  [879,127]
]
book_ids.each do |ids|
  params = Book.scrape_from_id(ids)
  Book.create(params)
end


# course = Course.new(
#   title: 'チェーホフ完読コース',
#   owner_id: 1
# )
# Book.all.each.with_index(1) do |book, index|
#   course.course_books.build(
#     book_id: book.id,
#     index: index
#   )
# end
# course.save!
