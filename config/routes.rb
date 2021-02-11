Rails.application.routes.draw do
  resources :subscriptions
  delete '/subscriptions' => 'subscriptions#destroy'

  resources :lists do
    get 'books', on: :member
  end
  get '/campaigns/dogramagra' => "pages#dogramagra"
  get ':page' => "pages#show", as: :page

  root to: 'pages#lp'
end
