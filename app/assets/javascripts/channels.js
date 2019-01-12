/***********************************************
* Events
***********************************************/
document.addEventListener("turbolinks:load", () => {
  // channels#new, channels#edit以外はスキップ
  if(document.body.dataset.controller != 'channels' || !['new', 'edit', 'create', 'update'].includes(document.body.dataset.action)) { return false; }

  // Sortable
  var el = document.getElementById('bookList');
  var sortable = Sortable.create(el, {
    handle: ".icon.content",
    sort: true,
    onEnd: setItemIndex
  });
});


/***********************************************
* Functions
***********************************************/
function removeBook(book_id) {
  var element = document.getElementById(book_id);

  document.getElementById(book_id+'_destroy').value = "true";
  element.style.display = 'none';

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
