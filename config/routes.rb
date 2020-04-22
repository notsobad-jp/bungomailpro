# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                                Controller#Action
#                     users GET    /:locale/users(.:format)                                                                   mail/users#index {:subdomain=>"", :locale=>/ja|en/}
#                           POST   /:locale/users(.:format)                                                                   mail/users#create {:subdomain=>"", :locale=>/ja|en/}
#                  new_user GET    /:locale/users/new(.:format)                                                               mail/users#new {:subdomain=>"", :locale=>/ja|en/}
#                 edit_user GET    /:locale/users/:id/edit(.:format)                                                          mail/users#edit {:subdomain=>"", :locale=>/ja|en/}
#                      user GET    /:locale/users/:id(.:format)                                                               mail/users#show {:subdomain=>"", :locale=>/ja|en/}
#                           PATCH  /:locale/users/:id(.:format)                                                               mail/users#update {:subdomain=>"", :locale=>/ja|en/}
#                           PUT    /:locale/users/:id(.:format)                                                               mail/users#update {:subdomain=>"", :locale=>/ja|en/}
#                           DELETE /:locale/users/:id(.:format)                                                               mail/users#destroy {:subdomain=>"", :locale=>/ja|en/}
#              magic_tokens GET    /:locale/magic_tokens(.:format)                                                            mail/magic_tokens#index {:subdomain=>"", :locale=>/ja|en/}
#                           POST   /:locale/magic_tokens(.:format)                                                            mail/magic_tokens#create {:subdomain=>"", :locale=>/ja|en/}
#           new_magic_token GET    /:locale/magic_tokens/new(.:format)                                                        mail/magic_tokens#new {:subdomain=>"", :locale=>/ja|en/}
#          edit_magic_token GET    /:locale/magic_tokens/:id/edit(.:format)                                                   mail/magic_tokens#edit {:subdomain=>"", :locale=>/ja|en/}
#               magic_token GET    /:locale/magic_tokens/:id(.:format)                                                        mail/magic_tokens#show {:subdomain=>"", :locale=>/ja|en/}
#                           PATCH  /:locale/magic_tokens/:id(.:format)                                                        mail/magic_tokens#update {:subdomain=>"", :locale=>/ja|en/}
#                           PUT    /:locale/magic_tokens/:id(.:format)                                                        mail/magic_tokens#update {:subdomain=>"", :locale=>/ja|en/}
#                           DELETE /:locale/magic_tokens/:id(.:format)                                                        mail/magic_tokens#destroy {:subdomain=>"", :locale=>/ja|en/}
#                     books GET    /:locale/books(.:format)                                                                   mail/books#index {:subdomain=>"", :locale=>/ja|en/}
#                      book GET    /:locale/books/:id(.:format)                                                               mail/books#show {:subdomain=>"", :locale=>/ja|en/}
#     channel_subscriptions GET    /:locale/channels/:channel_id/subscriptions(.:format)                                      mail/subscriptions#index {:subdomain=>"", :locale=>/ja|en/}
#                           POST   /:locale/channels/:channel_id/subscriptions(.:format)                                      mail/subscriptions#create {:subdomain=>"", :locale=>/ja|en/}
#  new_channel_subscription GET    /:locale/channels/:channel_id/subscriptions/new(.:format)                                  mail/subscriptions#new {:subdomain=>"", :locale=>/ja|en/}
#         edit_subscription GET    /:locale/subscriptions/:id/edit(.:format)                                                  mail/subscriptions#edit {:subdomain=>"", :locale=>/ja|en/}
#              subscription GET    /:locale/subscriptions/:id(.:format)                                                       mail/subscriptions#show {:subdomain=>"", :locale=>/ja|en/}
#                           PATCH  /:locale/subscriptions/:id(.:format)                                                       mail/subscriptions#update {:subdomain=>"", :locale=>/ja|en/}
#                           PUT    /:locale/subscriptions/:id(.:format)                                                       mail/subscriptions#update {:subdomain=>"", :locale=>/ja|en/}
#                           DELETE /:locale/subscriptions/:id(.:format)                                                       mail/subscriptions#destroy {:subdomain=>"", :locale=>/ja|en/}
#                  channels GET    /:locale/channels(.:format)                                                                mail/channels#index {:subdomain=>"", :locale=>/ja|en/}
#                           POST   /:locale/channels(.:format)                                                                mail/channels#create {:subdomain=>"", :locale=>/ja|en/}
#               new_channel GET    /:locale/channels/new(.:format)                                                            mail/channels#new {:subdomain=>"", :locale=>/ja|en/}
#              edit_channel GET    /:locale/channels/:id/edit(.:format)                                                       mail/channels#edit {:subdomain=>"", :locale=>/ja|en/}
#                   channel GET    /:locale/channels/:id(.:format)                                                            mail/channels#show {:subdomain=>"", :locale=>/ja|en/}
#                           PATCH  /:locale/channels/:id(.:format)                                                            mail/channels#update {:subdomain=>"", :locale=>/ja|en/}
#                           PUT    /:locale/channels/:id(.:format)                                                            mail/channels#update {:subdomain=>"", :locale=>/ja|en/}
#                           DELETE /:locale/channels/:id(.:format)                                                            mail/channels#destroy {:subdomain=>"", :locale=>/ja|en/}
#      skip_book_assignment POST   /:locale/book_assignments/:id/skip(.:format)                                               mail/book_assignments#skip {:subdomain=>"", :locale=>/ja|en/}
#          book_assignments GET    /:locale/book_assignments(.:format)                                                        mail/book_assignments#index {:subdomain=>"", :locale=>/ja|en/}
#                           POST   /:locale/book_assignments(.:format)                                                        mail/book_assignments#create {:subdomain=>"", :locale=>/ja|en/}
#       new_book_assignment GET    /:locale/book_assignments/new(.:format)                                                    mail/book_assignments#new {:subdomain=>"", :locale=>/ja|en/}
#      edit_book_assignment GET    /:locale/book_assignments/:id/edit(.:format)                                               mail/book_assignments#edit {:subdomain=>"", :locale=>/ja|en/}
#           book_assignment GET    /:locale/book_assignments/:id(.:format)                                                    mail/book_assignments#show {:subdomain=>"", :locale=>/ja|en/}
#                           PATCH  /:locale/book_assignments/:id(.:format)                                                    mail/book_assignments#update {:subdomain=>"", :locale=>/ja|en/}
#                           PUT    /:locale/book_assignments/:id(.:format)                                                    mail/book_assignments#update {:subdomain=>"", :locale=>/ja|en/}
#                           DELETE /:locale/book_assignments/:id(.:format)                                                    mail/book_assignments#destroy {:subdomain=>"", :locale=>/ja|en/}
#                     login GET    /:locale/login(.:format)                                                                   mail/magic_tokens#new {:subdomain=>"", :locale=>/ja|en/}
#                    logout POST   /:locale/logout(.:format)                                                                  mail/magic_tokens#destroy {:subdomain=>"", :locale=>/ja|en/}
#                      auth GET    /:locale/auth(.:format)                                                                    mail/magic_tokens#auth {:subdomain=>"", :locale=>/ja|en/}
#      campaigns_dogramagra GET    /:locale/campaigns/dogramagra(.:format)                                                    mail/pages#dogramagra {:subdomain=>"", :locale=>/ja|en/}
#                           GET    /:locale/:locale(.:format)                                                                 mail/pages#lp {:subdomain=>"", :locale=>/ja|en/}
#                      page GET    /:locale/:page(.:format)                                                                   mail/pages#show {:subdomain=>"", :locale=>/ja|en/}
#                      root GET    /:locale(.:format)                                                                         mail/pages#lp {:subdomain=>"", :locale=>/ja|en/}
#                           GET    /                                                                                          mail/pages#lp {:subdomain=>""}
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
#                           GET    (/:locale)(/:juvenile)/:locale(.:format)                                                   search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           GET    (/:locale)(/:juvenile)/:juvenile(.:format)                                                 search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           GET    (/:locale)(/:juvenile)/:locale/:juvenile(.:format)                                         search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#               search_root GET    /(/:locale)(/:juvenile)(.:format)                                                          search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           GET    /:locale(.:format)                                                                         search/books#index {:subdomain=>"search"}
#             juvenile_root GET    /:juvenile(.:format)                                                                       search/books#index {:subdomain=>"search"}
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                 active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)   active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                        active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                             active_storage/direct_uploads#create

Rails.application.routes.draw do
  # Bungo Mail
  constraints subdomain: '' do
    scope module: :mail do
      scope ":locale", locale: /ja|en/ do
        resources :users
        resources :magic_tokens
        resources :books, only: [:index, :show]
        resources :channels, shallow: true do
          resources :subscriptions
        end
        resources :book_assignments do
          post 'skip', on: :member
        end

        get 'login' => 'magic_tokens#new'
        post 'logout' => 'magic_tokens#destroy'
        get 'auth' => 'magic_tokens#auth'

        get '/campaigns/dogramagra' => "pages#dogramagra"
        get '/:locale' => 'pages#lp'
        get ':page' => "pages#show", as: :page

        root to: 'pages#lp'
      end
      get '/' => 'pages#lp'
    end
  end

  # Bungo Search
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
