Rails.application.routes.draw do
  resources :magic_tokens
  resources :memberships do
    get 'completed', on: :collection
  end
  resources :subscriptions
  resources :channels do
    get :feed, on: :member, defaults: { format: :rss }
  end
  resources :book_assignments
  resources :users do
    get 'activate', on: :member
  end
  resources :aozora_books, only: [:index, :show]

  get 'signup' => 'users#new'
  get 'login' => 'magic_tokens#new'
  delete 'logout' => 'magic_tokens#destroy'
  get 'auth' => 'magic_tokens#auth'
  get '/campaigns/dogramagra' => "pages#dogramagra"
  get 'mypage' => "users#mypage"

  # TODO: 新システム移行後は不要
  resources :channel_subscriptions
  resources :lists do
    get 'books', on: :member
  end
  delete '/channel_subscriptions' => 'channel_subscriptions#destroy'

  get ':page' => "pages#show", as: :page
  root to: 'pages#lp'
end
