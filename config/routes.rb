Rails.application.routes.draw do
  apipie
  root 'accounts#index'

  resources :accounts, only: %i[index new create]
  resources :transfer, only: %i[new create show]
  resources :deposit, only: %i[new create show]
  resources :withdrawal, only: %i[new create show]
  resources :operations, only: %i[show]

  resource :profile, only: %i[edit update]
  resource :password, only: %i[edit update]
  resources :sessions, only: %i[new create destroy]
  get 'api', to: 'apipie/apipies#index'

  namespace :api do
    resources :accounts do
      resources :cards
      resources :operations
    end
    resources :cards do
      post :auth, on: :collection
    end
    resources :operations
  end
end
