Rails.application.routes.draw do
  root 'accounts#index'

  resources :accounts

  get 'log-in', to: 'sessions#new'
  post 'log-in', to: 'sessions#create'
  get 'log-out', to: 'sessions#destroy'
end
