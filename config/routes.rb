# == Route Map
#
#                       Prefix Verb   URI Pattern                                                                              Controller#Action
#                books_channel POST   /channels/:id/books(.:format)                                                            channel_books#create
#                     channels GET    /channels(.:format)                                                                      channels#index
#                              POST   /channels(.:format)                                                                      channels#create
#                  new_channel GET    /channels/new(.:format)                                                                  channels#new
#                 edit_channel GET    /channels/:id/edit(.:format)                                                             channels#edit
#                      channel GET    /channels/:id(.:format)                                                                  channels#show
#                              PATCH  /channels/:id(.:format)                                                                  channels#update
#                              PUT    /channels/:id(.:format)                                                                  channels#update
#                              DELETE /channels/:id(.:format)                                                                  channels#destroy
#                        books GET    /books(.:format)                                                                         books#index
#                              POST   /books(.:format)                                                                         books#create
#                     new_book GET    /books/new(.:format)                                                                     books#new
#                    edit_book GET    /books/:id/edit(.:format)                                                                books#edit
#                         book GET    /books/:id(.:format)                                                                     books#show
#                              PATCH  /books/:id(.:format)                                                                     books#update
#                              PUT    /books/:id(.:format)                                                                     books#update
#                              DELETE /books/:id(.:format)                                                                     books#destroy
#                subscriptions GET    /subscriptions(.:format)                                                                 subscriptions#index
#                              POST   /subscriptions(.:format)                                                                 subscriptions#create
#             new_subscription GET    /subscriptions/new(.:format)                                                             subscriptions#new
#            edit_subscription GET    /subscriptions/:id/edit(.:format)                                                        subscriptions#edit
#                 subscription GET    /subscriptions/:id(.:format)                                                             subscriptions#show
#                              PATCH  /subscriptions/:id(.:format)                                                             subscriptions#update
#                              PUT    /subscriptions/:id(.:format)                                                             subscriptions#update
#                              DELETE /subscriptions/:id(.:format)                                                             subscriptions#destroy
#                 magic_tokens GET    /magic_tokens(.:format)                                                                  magic_tokens#index
#                              POST   /magic_tokens(.:format)                                                                  magic_tokens#create
#              new_magic_token GET    /magic_tokens/new(.:format)                                                              magic_tokens#new
#             edit_magic_token GET    /magic_tokens/:id/edit(.:format)                                                         magic_tokens#edit
#                  magic_token GET    /magic_tokens/:id(.:format)                                                              magic_tokens#show
#                              PATCH  /magic_tokens/:id(.:format)                                                              magic_tokens#update
#                              PUT    /magic_tokens/:id(.:format)                                                              magic_tokens#update
#                              DELETE /magic_tokens/:id(.:format)                                                              magic_tokens#destroy
#       update_payment_charges GET    /charges/update_payment(.:format)                                                        charges#update_payment
#                      charges GET    /charges(.:format)                                                                       charges#index
#                              POST   /charges(.:format)                                                                       charges#create
#                   new_charge GET    /charges/new(.:format)                                                                   charges#new
#                  edit_charge GET    /charges/:id/edit(.:format)                                                              charges#edit
#                       charge GET    /charges/:id(.:format)                                                                   charges#show
#                              PATCH  /charges/:id(.:format)                                                                   charges#update
#                              PUT    /charges/:id(.:format)                                                                   charges#update
#                              DELETE /charges/:id(.:format)                                                                   charges#destroy
# webhooks_update_subscription GET    /webhooks/update_subscription(.:format)                                                  webhooks#update_subscription
#                         user GET    /users/:token(.:format)                                                                  users#show
#                     pro_root GET    /pro(.:format)                                                                           pages#top
#                        login GET    /login(.:format)                                                                         magic_tokens#new
#                         auth GET    /auth(.:format)                                                                          magic_tokens#auth
#                       logout POST   /logout(.:format)                                                                        magic_tokens#destroy
#                         root GET    /                                                                                        pages#top
#           rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#    rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#           rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#    update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#         rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

Rails.application.routes.draw do
  resources :channels do
    post 'books' => 'channel_books#create', on: :member
  end
  resources :books
  resources :subscriptions
  resources :magic_tokens
  resources :charges do
    get 'update_payment', on: :collection
  end

  post 'webhooks/update_subscription'

  get 'users/:token' => 'users#show', as: :user
  get 'pro' => 'pages#top', as: :pro_root

  get 'login' => 'magic_tokens#new', as: :login
  get 'auth' => 'magic_tokens#auth', as: :auth
  post 'logout' => 'magic_tokens#destroy', as: :logout

  root to: 'pages#top'
end
