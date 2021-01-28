const purgecss = require('@fullhuman/postcss-purgecss')({
  content: [
    'app/views/**/*.haml',
    'app/views/**/*.haml',
    'app/helpers/*.rb',
    'config/locales/**/*.yml',
  ],
  defaultExtractor: content => content.match(/[^<>"'.`\s]*[^.<>"'`\s:]/g) || [],
})

const cssnano = require('cssnano')({
  preset: 'default',
})

module.exports = {
  plugins: [
    require('postcss-import'),
    require('postcss-flexbugs-fixes'),
    require("tailwindcss"),
    require("autoprefixer"),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    }),
    ...(process.env.NODE_ENV === 'production' ? [purgecss, cssnano] : []),
  ]
}
