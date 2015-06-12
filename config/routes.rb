require 'sidekiq/web'

Mangar::Application.routes.draw do
  resources :items do
    member do
      get :more_info
    end
    collection do
      get :import_and_update
      get :bulk_export
      get :info
      get :quit
    end
  end

  resources :books, only: [:show]
  resources :videos, only: [:show]

  resources :preferences

  root to: "items#index"

  mount Sidekiq::Web => '/sidekiq'
end
