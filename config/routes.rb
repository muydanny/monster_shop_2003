Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'welcome#index'

  get "/login", action: :new, controller: "sessions"
  post "/login", action: :create, controller: "sessions"
  delete "/logout", action: :destroy, controller: "sessions"

  get "/admin", action: :show, controller: "admins"

  namespace :admin do
    resources :merchants, only: [:show, :index]
    resources :users, only: [:index]
    resources :orders, only: [:update]

    resources :users, only: [:show] do 
      resources :orders, only: [:show]
    end

    get "/profile/:user_id", action: :show, controller: "users"
    get "/merchants/status/:id", action: :update, controller: "merchants"
  end

  get "/merchant", to: "merchant#show"

  namespace :merchant do
    get '/orders/:order_id', to: 'orders#show'
    patch '/orders/:order_id', to: 'orders#update'
    get '/items', to: 'items#index'
    get '/items/:id/status', to: 'items#status'
    get '/items/:id/edit', to: 'items#edit'
    patch '/items/:id', to: 'items#update'
    delete '/items/:id', to: 'items#destroy'
    get '/items/new', to: 'items#new'
    post '/items', to: 'items#create'
  end

  get "/merchants", to: "merchants#index"
  get "/merchants/new", to: "merchants#new"
  get "/merchants/:id", to: "merchants#show"
  post "/merchants", to: "merchants#create"
  get "/merchants/:id/edit", to: "merchants#edit"
  patch "/merchants/:id", to: "merchants#update"
  delete "/merchants/:id", to: "merchants#destroy"

  get "/items", to: "items#index"
  get "/items/:id", to: "items#show"
  get "/items/:id/edit", to: "items#edit"
  patch "/items/:id", to: "items#update"
  delete "/items/:id", to: "items#destroy"

  get "/merchants/:merchant_id/items", to: "merchants_items#index"
  get "/merchants/:merchant_id/items/new", to: "merchants_items#new"
  post "/merchants/:merchant_id/items", to: "merchants_items#create"

  get "/items/:item_id/reviews/new", to: "reviews#new"
  post "/items/:item_id/reviews", to: "reviews#create"

  get "/reviews/:id/edit", to: "reviews#edit"
  patch "/reviews/:id", to: "reviews#update"
  delete "/reviews/:id", to: "reviews#destroy"

  get "/cart", action: :show, controller: "cart"
  delete "/cart", action: :destroy, controller: "cart"

  namespace :cart do
    post "/:item_id", action: :new "items"
    delete "/:item_id", action: :destroy "items"
    patch "/:item_id", to: :update "items"
  end

  get "/profile", to: "users#show"
  get "/register", to: "users#new"
  post "/users", to: "users#create"
  get "/profile/edit", to: "users#edit"
  post "/profile", to: "users#update"

  get "/password/edit", to: "password#edit"
  post "/password", to: "password#update"

  get "/orders/new", to: "orders#new"
  post "/orders", to: "orders#create"
  get "/profile/orders/:id", to: "orders#show"
  get "/profile/orders", to: "orders#index"
  patch "/profile/orders/:id", to: "orders#update"

  get "error404", action: :show, controller: "errors"
end
