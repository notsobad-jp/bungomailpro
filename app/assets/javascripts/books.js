/***********************************************
* Events
***********************************************/
document.addEventListener("turbolinks:load", () => {
  // books#index, pages#top以外はスキップ
  if(document.body.dataset.path != 'books#index' && document.body.dataset.path != 'pages#top') { return false; }

  let dimmer = document.getElementById('dimmer');

  document.body.addEventListener('ajax:before', (event) => {
    dimmer.classList.add('active');
  })
  document.body.addEventListener('ajax:success', (event) => {
    let res = event.detail[0];
    alert(`${res.channel}に「${res.book}」を追加しました！`);
  })
  document.body.addEventListener('ajax:error', (event) => {
    alert("チャネルへの追加に失敗しました…");
  })
  document.body.addEventListener('ajax:complete', (event) => {
    dimmer.classList.remove('active');
  })
})
