# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                                Controller#Action
#                        en GET    /en(.:format)                                                                              redirect(301, subdomain: en, path: /) {:subdomain=>""}
#      campaigns_dogramagra GET    /campaigns/dogramagra(.:format)                                                            pages#dogramagra {:subdomain=>""}
#                      page GET    /:page(.:format)                                                                           pages#show {:subdomain=>""}
#                      root GET    /                                                                                          pages#lp {:subdomain=>""}
#                     users GET    /users(.:format)                                                                           en/users#index {:subdomain=>"en"}
#                           POST   /users(.:format)                                                                           en/users#create {:subdomain=>"en"}
#                  new_user GET    /users/new(.:format)                                                                       en/users#new {:subdomain=>"en"}
#                 edit_user GET    /users/:id/edit(.:format)                                                                  en/users#edit {:subdomain=>"en"}
#                      user GET    /users/:id(.:format)                                                                       en/users#show {:subdomain=>"en"}
#                           PATCH  /users/:id(.:format)                                                                       en/users#update {:subdomain=>"en"}
#                           PUT    /users/:id(.:format)                                                                       en/users#update {:subdomain=>"en"}
#                           DELETE /users/:id(.:format)                                                                       en/users#destroy {:subdomain=>"en"}
#              magic_tokens GET    /magic_tokens(.:format)                                                                    en/magic_tokens#index {:subdomain=>"en"}
#                           POST   /magic_tokens(.:format)                                                                    en/magic_tokens#create {:subdomain=>"en"}
#           new_magic_token GET    /magic_tokens/new(.:format)                                                                en/magic_tokens#new {:subdomain=>"en"}
#          edit_magic_token GET    /magic_tokens/:id/edit(.:format)                                                           en/magic_tokens#edit {:subdomain=>"en"}
#               magic_token GET    /magic_tokens/:id(.:format)                                                                en/magic_tokens#show {:subdomain=>"en"}
#                           PATCH  /magic_tokens/:id(.:format)                                                                en/magic_tokens#update {:subdomain=>"en"}
#                           PUT    /magic_tokens/:id(.:format)                                                                en/magic_tokens#update {:subdomain=>"en"}
#                           DELETE /magic_tokens/:id(.:format)                                                                en/magic_tokens#destroy {:subdomain=>"en"}
#      skip_book_assignment POST   /book_assignments/:id/skip(.:format)                                                       en/book_assignments#skip {:subdomain=>"en"}
#          book_assignments GET    /book_assignments(.:format)                                                                en/book_assignments#index {:subdomain=>"en"}
#                           POST   /book_assignments(.:format)                                                                en/book_assignments#create {:subdomain=>"en"}
#       new_book_assignment GET    /book_assignments/new(.:format)                                                            en/book_assignments#new {:subdomain=>"en"}
#      edit_book_assignment GET    /book_assignments/:id/edit(.:format)                                                       en/book_assignments#edit {:subdomain=>"en"}
#           book_assignment GET    /book_assignments/:id(.:format)                                                            en/book_assignments#show {:subdomain=>"en"}
#                           PATCH  /book_assignments/:id(.:format)                                                            en/book_assignments#update {:subdomain=>"en"}
#                           PUT    /book_assignments/:id(.:format)                                                            en/book_assignments#update {:subdomain=>"en"}
#                           DELETE /book_assignments/:id(.:format)                                                            en/book_assignments#destroy {:subdomain=>"en"}
#                     login GET    /login(.:format)                                                                           en/magic_tokens#new {:subdomain=>"en"}
#                    logout POST   /logout(.:format)                                                                          en/magic_tokens#destroy {:subdomain=>"en"}
#                      auth GET    /auth(.:format)                                                                            en/magic_tokens#auth {:subdomain=>"en"}
#                    mypage GET    /mypage(.:format)                                                                          en/users#mypage {:subdomain=>"en"}
#                   en_root GET    /                                                                                          en/pages#lp {:subdomain=>"en"}
#     author_category_books GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books(.:format)          search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           POST   (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books(.:format)          search/books#create {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#  new_author_category_book GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/new(.:format)      search/books#new {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
# edit_author_category_book GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/:id/edit(.:format) search/books#edit {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#      author_category_book GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/:id(.:format)      search/books#show {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PATCH  (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/:id(.:format)      search/books#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PUT    (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/:id(.:format)      search/books#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           DELETE (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/:id(.:format)      search/books#destroy {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#         author_categories GET    (/:locale)(/:juvenile)/authors/:author_id/categories(.:format)                             search/categories#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           POST   (/:locale)(/:juvenile)/authors/:author_id/categories(.:format)                             search/categories#create {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#       new_author_category GET    (/:locale)(/:juvenile)/authors/:author_id/categories/new(.:format)                         search/categories#new {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#      edit_author_category GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:id/edit(.:format)                    search/categories#edit {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#           author_category GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:id(.:format)                         search/categories#show {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PATCH  (/:locale)(/:juvenile)/authors/:author_id/categories/:id(.:format)                         search/categories#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PUT    (/:locale)(/:juvenile)/authors/:author_id/categories/:id(.:format)                         search/categories#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           DELETE (/:locale)(/:juvenile)/authors/:author_id/categories/:id(.:format)                         search/categories#destroy {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                   authors GET    (/:locale)(/:juvenile)/authors(.:format)                                                   search/authors#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           POST   (/:locale)(/:juvenile)/authors(.:format)                                                   search/authors#create {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                new_author GET    (/:locale)(/:juvenile)/authors/new(.:format)                                               search/authors#new {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#               edit_author GET    (/:locale)(/:juvenile)/authors/:id/edit(.:format)                                          search/authors#edit {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                    author GET    (/:locale)(/:juvenile)/authors/:id(.:format)                                               search/authors#show {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PATCH  (/:locale)(/:juvenile)/authors/:id(.:format)                                               search/authors#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PUT    (/:locale)(/:juvenile)/authors/:id(.:format)                                               search/authors#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           DELETE (/:locale)(/:juvenile)/authors/:id(.:format)                                               search/authors#destroy {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                about_page GET    (/:locale)(/:juvenile)/about(.:format)                                                     search/pages#about {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#               locale_root GET    (/:locale)(/:juvenile)/:locale(.:format)                                                   search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#             juvenile_root GET    (/:locale)(/:juvenile)/:juvenile(.:format)                                                 search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#               search_root GET    /(/:locale)(/:juvenile)(.:format)                                                          search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                 active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)   active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                        active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                             active_storage/direct_uploads#create

Rails.application.routes.draw do
  # 国内版ブンゴウメール
  constraints subdomain: '' do
    #TMP: 海外版旧URL（サブディレクトリ）から新URL（サブドメイン）にリダイレクト
    get  "/en" => redirect(subdomain: :en, path: '/')

    get '/campaigns/dogramagra' => "pages#dogramagra"
    get '/:page' => "pages#show", as: :page

    root to: 'pages#lp'
  end

  # English ver.
  constraints subdomain: 'en' do
    scope module: :en do
      resources :users
      resources :magic_tokens
      resources :book_assignments do
        post 'skip', on: :member
      end

      get 'login' => 'magic_tokens#new'
      post 'logout' => 'magic_tokens#destroy'
      get 'auth' => 'magic_tokens#auth'
      get 'mypage' => "users#mypage", as: :mypage

      get '/' => 'pages#lp', as: :en_root
    end
  end

  # ZORA SEARCH
  constraints subdomain: 'search' do
    scope module: :search do
      scope "(:locale)", locale: /ja|en/ do
        scope "(:juvenile)", juvenile: /juvenile/ do
          resources :authors do
            resources :categories do
              resources :books
            end
          end
          get '/about' => "pages#about", as: :about_page
          get '/:locale' => 'books#index'
          get '/:juvenile' => 'books#index'
          get '/:locale/:juvenile' => 'books#index'
          root :to => 'books#index', as: :search_root
        end
      end
      get '/:locale' => 'books#index'
      get '/:juvenile' => 'books#index', as: :juvenile_root
    end
  end
end
