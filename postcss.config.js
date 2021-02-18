const hash = require('postcss-hash')({
  algorithm: 'sha256',
  trim: 20,
  manifest: './tmp/csv_version.json'
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
    ...(process.env.NODE_ENV === 'production' ? [cssnano, hash] : []),
  ]
}
