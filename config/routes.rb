Rails.application.routes.draw do
  scope "(:locale)", locale: /ja|en/ do
    scope "(:juvenile)", juvenile: /juvenile/ do
      resources :authors do
        resources :categories do
          resources :books
        end
      end
      get '/about' => "pages#about", as: :about_page
      get '/ranking/:year' => "pages#ranking", as: :ranking
      get '/:locale' => 'books#index'
      get '/:juvenile' => 'books#index'
      get '/:locale/:juvenile' => 'books#index'
      root :to => 'books#index', as: :search_root
    end
  end
  get '/:locale' => 'books#index'
  get '/:juvenile' => 'books#index', as: :juvenile_root
end
