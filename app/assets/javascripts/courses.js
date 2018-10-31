/***********************************************
* Events
***********************************************/
document.addEventListener("turbolinks:load", () => {
  // courses#new, courses#edit以外はスキップ
  if(document.body.dataset.controller != 'courses' || !['new', 'edit'].includes(document.body.dataset.action)) { return false; }


  // Sortable
  var el = document.getElementById('bookList');
  var sortable = Sortable.create(el, {
    handle: ".icon.content",
    sort: true,
    onEnd: setItemIndex
  });



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

    var element = document.getElementById(data['id']);
    if(element) {
      var destroy_flg = document.getElementById(data['id']+'_destroy');
      if(destroy_flg.value=='true') {
        destroy_flg.value = 'false'
        element.style.display = 'block';
      }else {
        alert('その本はもうリストに追加されているようです。他の本をお試しください。')
      }
    }else {
      addBook(data);
    }
  })
  document.body.addEventListener('ajax:error', (event) => {
    document.getElementById('loader').classList.replace('active', 'disabled');
    alert('データの追加に失敗しました(´；ω；｀) URLを再度ご確認いただき、それでも追加できない場合は運営までお問い合わせください。')
  })
})



/***********************************************
* Functions
***********************************************/
function addBook(data) {
  var bookList = document.getElementById('bookList');
  var index = bookList.childElementCount;

  var item = document.createElement('div');
  item.setAttribute('id', data['id']);
  item.setAttribute('class', 'item');
  item.innerHTML = `
    <div class="right floated content">
      <div class="ui icon basic button" onclick="removeBook(${ data['id'] })">
        <i class="icon remove"></i>
      </div>
    </div>
    <i class="icon content"></i>
    <div class="content">
      <div class="header">
        ${ data['author'] }『${ data['title'] }』
        <small><a href="#" target="_blank"><i class="icon external"></i></a></small>
      </div>
      <div class="description">
        <small>文字数：約12,000字</small>
        <input value="${ data['id'] }" type="hidden" name="course[course_books_attributes][${ index }][book_id]">
        <input id="${ data['id'] }_index" value="${ index + 1 }" type="hidden" name="course[course_books_attributes][${ index }][index]">
        <input id="${ data['id'] }_destroy" value="false" type="hidden" name="course[course_books_attributes][${ index }][_destroy]">
        <input value="" type="hidden" name="course[course_books_attributes][${ index }][id]">
      </div>
    </div>
  `;

  bookList.appendChild(item);
  setItemIndex();
}


function removeBook(book_id) {
  var element = document.getElementById(book_id);
  var saved = element.hasAttribute('data-saved');

  // 元から存在するitemは削除フラグをつけて隠す
  if(saved) {
    document.getElementById(book_id+'_destroy').value = "true";
    element.style.display = 'none';
  // あとから追加したitemはそのまま削除
  }else {
    element.parentNode.removeChild(element);
  }

  // index振り直し
  setItemIndex();
}


function setItemIndex() {
  var booklist = document.getElementById('bookList');
  var index = 1;
  for (var i = 0; i < booklist.children.length; i++) {
    var book_id = booklist.children[i].getAttribute('id');

    // 削除フラグのついたitemはスキップ
    if(document.getElementById(book_id + '_destroy').value == 'true') { continue };

    // indexセット
    document.getElementById(book_id + '_index').value = index;
    index++;
  }
}


function setScrapeUrl(e) {
  var baseHref = '/books/scrape/?url=';
  var searchButton = e.currentTarget;
  var searchInput = document.getElementById("searchInput");
  searchButton.setAttribute('href', baseHref + searchInput.value);
  searchInput.value = '';
}
