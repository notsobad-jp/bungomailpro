# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                              Controller#Action
#                        en GET    /en(.:format)                                                                            redirect(301, subdomain: en, path: /) {:subdomain=>""}
#      campaigns_dogramagra GET    /campaigns/dogramagra(.:format)                                                          pages#dogramagra {:subdomain=>""}
#                      page GET    /:page(.:format)                                                                         pages#show {:subdomain=>""}
#                      root GET    /                                                                                        pages#lp {:subdomain=>""}
#                     users GET    /users(.:format)                                                                         en/users#index {:subdomain=>"en"}
#                           POST   /users(.:format)                                                                         en/users#create {:subdomain=>"en"}
#                  new_user GET    /users/new(.:format)                                                                     en/users#new {:subdomain=>"en"}
#                 edit_user GET    /users/:id/edit(.:format)                                                                en/users#edit {:subdomain=>"en"}
#                      user GET    /users/:id(.:format)                                                                     en/users#show {:subdomain=>"en"}
#                           PATCH  /users/:id(.:format)                                                                     en/users#update {:subdomain=>"en"}
#                           PUT    /users/:id(.:format)                                                                     en/users#update {:subdomain=>"en"}
#                           DELETE /users/:id(.:format)                                                                     en/users#destroy {:subdomain=>"en"}
#                     login GET    /login(.:format)                                                                         en/magic_tokens#new {:subdomain=>"en"}
#                      auth GET    /auth(.:format)                                                                          en/magic_tokens#auth {:subdomain=>"en"}
#                    logout POST   /logout(.:format)                                                                        en/magic_tokens#destroy {:subdomain=>"en"}
#                    mypage GET    /mypage(.:format)                                                                        en/users#mypage {:subdomain=>"en"}
#                           GET    /                                                                                        en/pages#lp {:subdomain=>"en"}
#     author_category_books GET    /authors/:author_id/categories/:category_id/books(.:format)                              search/books#index {:subdomain=>"search"}
#                           POST   /authors/:author_id/categories/:category_id/books(.:format)                              search/books#create {:subdomain=>"search"}
#  new_author_category_book GET    /authors/:author_id/categories/:category_id/books/new(.:format)                          search/books#new {:subdomain=>"search"}
# edit_author_category_book GET    /authors/:author_id/categories/:category_id/books/:id/edit(.:format)                     search/books#edit {:subdomain=>"search"}
#      author_category_book GET    /authors/:author_id/categories/:category_id/books/:id(.:format)                          search/books#show {:subdomain=>"search"}
#                           PATCH  /authors/:author_id/categories/:category_id/books/:id(.:format)                          search/books#update {:subdomain=>"search"}
#                           PUT    /authors/:author_id/categories/:category_id/books/:id(.:format)                          search/books#update {:subdomain=>"search"}
#                           DELETE /authors/:author_id/categories/:category_id/books/:id(.:format)                          search/books#destroy {:subdomain=>"search"}
#         author_categories GET    /authors/:author_id/categories(.:format)                                                 search/categories#index {:subdomain=>"search"}
#                           POST   /authors/:author_id/categories(.:format)                                                 search/categories#create {:subdomain=>"search"}
#       new_author_category GET    /authors/:author_id/categories/new(.:format)                                             search/categories#new {:subdomain=>"search"}
#      edit_author_category GET    /authors/:author_id/categories/:id/edit(.:format)                                        search/categories#edit {:subdomain=>"search"}
#           author_category GET    /authors/:author_id/categories/:id(.:format)                                             search/categories#show {:subdomain=>"search"}
#                           PATCH  /authors/:author_id/categories/:id(.:format)                                             search/categories#update {:subdomain=>"search"}
#                           PUT    /authors/:author_id/categories/:id(.:format)                                             search/categories#update {:subdomain=>"search"}
#                           DELETE /authors/:author_id/categories/:id(.:format)                                             search/categories#destroy {:subdomain=>"search"}
#                   authors GET    /authors(.:format)                                                                       search/authors#index {:subdomain=>"search"}
#                           POST   /authors(.:format)                                                                       search/authors#create {:subdomain=>"search"}
#                new_author GET    /authors/new(.:format)                                                                   search/authors#new {:subdomain=>"search"}
#               edit_author GET    /authors/:id/edit(.:format)                                                              search/authors#edit {:subdomain=>"search"}
#                    author GET    /authors/:id(.:format)                                                                   search/authors#show {:subdomain=>"search"}
#                           PATCH  /authors/:id(.:format)                                                                   search/authors#update {:subdomain=>"search"}
#                           PUT    /authors/:id(.:format)                                                                   search/authors#update {:subdomain=>"search"}
#                           DELETE /authors/:id(.:format)                                                                   search/authors#destroy {:subdomain=>"search"}
#                           GET    /:page(.:format)                                                                         search/pages#show {:subdomain=>"search"}
#                           GET    /.amp(.:format)                                                                          search/books#index {:subdomain=>"search"}
#                           GET    /                                                                                        search/books#index {:subdomain=>"search"}
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

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

      get 'login' => 'magic_tokens#new'
      post 'logout' => 'magic_tokens#destroy'
      get 'auth' => 'magic_tokens#auth'
      get 'mypage' => "users#mypage", as: :mypage

      root to: 'pages#lp'
    end
  end

  # ZORA SEARCH
  constraints subdomain: 'search' do
    scope module: :search do
      resources :authors do
        resources :categories do
          resources :books
        end
      end
      get '/:page' => "pages#show"
      get '/.amp' => 'books#index'
      root to: 'books#index'
    end
  end
end
