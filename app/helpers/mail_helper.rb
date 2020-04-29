module MailHelper
  def books_path(book_type:)
    book_type == "AozoraBook" ? aozora_books_path : guten_books_path
  end

  def book_path(book_type:, id:)
    "#{book_type.underscore}_path(#{id})" rescue url_for
  end
end
