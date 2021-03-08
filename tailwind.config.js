const purge = {
  content: [
    'app/views/**/*.haml',
    'app/views/**/*.haml',
    'app/helpers/*.rb',
    'config/locales/**/*.yml',
  ],
}

module.exports = {
  purge: process.env.NODE_ENV === 'production' ? purge : {},
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      'sans': ['Noto Sans JP', 'ui-sans-serif', 'system-ui'],
    },
    extend: {},
  },
  variants: {
    extend: {
      textColor: ['visited'],
    },
  },
  plugins: [],
}
