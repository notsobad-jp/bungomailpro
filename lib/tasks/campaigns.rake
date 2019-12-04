namespace :campaigns do
  task read_file: :environment do |_task, _args|
    url = 'https://raw.githubusercontent.com/aozorabunko/aozorabunko/master/cards/000012/files/1092_20971.html'
    html = open(url, &:read)
    text, footnote = Book.new.aozora_file_text(html)
  end
end
