# README

## PostCSS
やってること

- tailwindを読み込み
- purgecssで不要なcssを削除
- cssnanoでminify

※AMP対応で、_meta.htmlで出力したcssを直接head内に読み込み・出力

## Development
railsサーバと並行して、postcss-cliでwatchしておく

> yarn watch

-> `public/assets/stylesheets/application.css` を出力

※localではpurgeしてない大きいやつ

## Production
deployしたら、本番用コマンドを自動実行

> yarn build

-> `public/assets/stylesheets/application.css` を出力
