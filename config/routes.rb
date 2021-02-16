Rails.application.routes.draw do
  resources :magic_tokens
  resources :memberships
  resources :channels do
    resources :book_assignments
  end
  resources :users do
    get 'activate', on: :member
  end

  get 'signup' => 'users#new'
  get 'login' => 'magic_tokens#new'
  delete 'logout' => 'magic_tokens#destroy'
  get 'auth' => 'magic_tokens#auth'
  get '/campaigns/dogramagra' => "pages#dogramagra"
  get 'mypage' => "users#show"

  # TODO: 新システム移行後は不要
  resources :subscriptions
  resources :lists do
    get 'books', on: :member
  end
  delete '/subscriptions' => 'subscriptions#destroy'

  get ':page' => "pages#show", as: :page
  root to: 'pages#lp'
end
