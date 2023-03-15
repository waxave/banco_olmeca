Rails.application.routes.draw do
  root 'accounts#index'

  resources :accounts, only: %i[index new create]
  resources :transfer, only: %i[new create]
  resources :deposit, only: %i[new create]
  resources :withdraw, only: %i[new create]

  get 'log-in', to: 'sessions#new'
  post 'log-in', to: 'sessions#create'
  get 'log-out', to: 'sessions#destroy'

  namespace :api do
    resources :accounts do
      resources :cards
      resources :operations
    end
    resources :cards
    resources :operations
  end
end
