namespace :tmp_tasks do
  desc "NewBookからBookの情報をアップデート"
  task :update_books => :environment do |task, args|
    BookNew.all.each do |new_book|
      book = Book.find_by(id: new_book.id)
      if book
        book.update!(
          author: new_book.author,
          author_id: new_book.author_id,
          chapters_count: new_book.chapters_count
        )
      else
        Book.create(new_book.attributes)
      end
      p "finished: #{new_book.id}"
    end
  end
end
