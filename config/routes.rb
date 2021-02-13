Rails.application.routes.draw do
  resources :subscriptions
  resources :magic_tokens
  resources :users
  resources :lists do
    get 'books', on: :member
  end

  delete '/subscriptions' => 'subscriptions#destroy'
  get 'signup' => 'users#new'
  get 'login' => 'magic_tokens#new'
  post 'logout' => 'magic_tokens#destroy'
  get 'auth' => 'magic_tokens#auth'
  get '/campaigns/dogramagra' => "pages#dogramagra"
  get ':page' => "pages#show", as: :page

  root to: 'pages#lp'
end
