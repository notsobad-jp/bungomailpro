Rails.application.routes.draw do
  namespace :memberships do
    get 'new'
    get 'create'
    get 'completed'
    get 'edit'
    post 'update'
  end

  resources :subscriptions
  resources :channels do
    get :feed, on: :member, defaults: { format: :rss }
  end
  resources :book_assignments

  get '/campaigns/dogramagra' => "pages#dogramagra"

  # TODO: 新システム移行後は不要
  get '/lp_new' => "pages#lp_new"
  resources :channel_subscriptions
  resources :lists do
    get 'books', on: :member
  end
  delete '/channel_subscriptions' => 'channel_subscriptions#destroy'

  get ':page' => "pages#show", as: :page
  root to: 'pages#lp'
end
