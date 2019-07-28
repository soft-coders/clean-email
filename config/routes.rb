Rails.application.routes.draw do
  resources :email_lists
  root to: 'email_lists#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
