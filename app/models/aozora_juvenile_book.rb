class AozoraJuvenileBook < AozoraBook
  default_scope { where(juvenile: true) }

  CATEGORIES = {
    all: {
      id: 'all',
      name: 'すべて',
      range_from: 1,
      range_to: 9999999,
      books_count: 1513
    },
    flash: {
      id: 'flash',
      name: '5分以内',
      title: '短編',
      range_from: 1,
      range_to: 2000,
      books_count: 461
    },
    shortshort: {
      id: 'shortshort',
      name: '10分以内',
      title: '短編',
      range_from: 2001,
      range_to: 4000,
      books_count: 316
    },
    short: {
      id: 'short',
      name: '30分以内',
      title: '短編',
      range_from: 4001,
      range_to: 12000,
      books_count: 507
    },
    novelette: {
      id: 'novelette',
      name: '60分以内',
      title: '中編',
      range_from: 12001,
      range_to: 24000,
      books_count: 98
    },
    novel: {
      id: 'novel',
      name: '1時間〜',
      title: '長編',
      range_from: 24001,
      range_to: 9999999,
      books_count: 131
    }
  }.freeze
end
