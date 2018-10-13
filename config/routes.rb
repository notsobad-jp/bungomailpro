Rails.application.routes.draw do
  resources :courses
  resources :magic_tokens
  resources :subscriptions
  resources :deliveries

  get 'login' => 'magic_tokens#new', as: :login
  get 'auth' => 'magic_tokens#auth', as: :auth
  post 'logout' => 'magic_tokens#destroy', as: :logout

  root to: 'pages#pro'
end
