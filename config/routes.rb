Rails.application.routes.draw do
  apipie
  root 'accounts#index'

  resources :accounts, only: %i[index new create]
  resources :transfer, only: %i[new create]
  resources :deposit, only: %i[new create]
  resources :withdraw, only: %i[new create]

  get 'log-in', to: 'sessions#new'
  post 'log-in', to: 'sessions#create'
  get 'log-out', to: 'sessions#destroy'
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
