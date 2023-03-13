Rails.application.routes.draw do
  root 'accounts#index'

  resources :accounts
  resources :sign_in, only: %i[new create]
end
