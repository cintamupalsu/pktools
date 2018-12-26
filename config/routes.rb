Rails.application.routes.draw do
  get  '/companies',        to: 'companies#index'
  get  '/companies/new',    to: 'companies#new'
  post '/companies/new',    to: 'companies#create'
  post '/companies/update', to: 'companies#update'
  
  get  '/yokyu',     to: 'yokyu#index'
  post '/learn',     to: 'yokyu#learn'
  post '/answer',    to: 'yokyu#answer'

  

  devise_for :users
  root 'pages#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :companies, only: [:show, :edit, :destroy]

end
