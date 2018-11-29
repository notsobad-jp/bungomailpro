/***********************************************
* Events
***********************************************/
document.addEventListener("turbolinks:load", () => {
  // courses#new, courses#edit以外はスキップ
  if(document.body.dataset.controller != 'books' || !['index'].includes(document.body.dataset.action)) { return false; }

  // 追加ボタンクリック時の送信前処理(URLセット、Loader表示)
  document.getElementById('searchButton').addEventListener('click', (e) => {
    setScrapeUrl(e);
    document.getElementById('loader').classList.replace('disabled', 'active');
  })


  // Ajaxで本のデータを受け取ってリストに追加
  document.body.addEventListener('ajax:success', (event) => {
    document.getElementById('loader').classList.replace('active', 'disabled');

    var detail = event.detail;
    var data = detail[0], status = detail[1],  xhr = detail[2];

    if(!data) {
      alert('データの追加に失敗しました(´；ω；｀) URLを再度ご確認いただき、それでも追加できない場合は運営までお問い合わせください。')
      return false;
    }
    alert('作品を追加しました🎉')
  })
  document.body.addEventListener('ajax:error', (event) => {
    document.getElementById('loader').classList.replace('active', 'disabled');
    alert('データの追加に失敗しました(´；ω；｀) URLを再度ご確認いただき、それでも追加できない場合は運営までお問い合わせください。')
  })
})



/***********************************************
* Functions
***********************************************/
function setScrapeUrl(e) {
  var baseHref = '/books/scrape/?url=';
  var searchButton = e.currentTarget;
  var searchInput = document.getElementById("searchInput");
  searchButton.setAttribute('href', baseHref + searchInput.value);
  searchInput.value = '';
}
