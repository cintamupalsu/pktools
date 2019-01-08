Rails.application.routes.draw do
  get    '/companies',        to: 'companies#index'
  get    '/companies/new',    to: 'companies#new'
  post   '/companies/new',    to: 'companies#create'
  post   '/companies/update', to: 'companies#update'
  
  get    '/questions',         to: 'yokyu#questions'
  get    '/question',          to: 'yokyu#question_show'
  get    '/question/new',      to: 'yokyu#question_new'
  post   '/question/new',      to: 'yokyu#question_create'
  get    '/question/edit',     to: 'yokyu#question_edit'
  post   '/question/edit',     to: 'yokyu#question_update'
  get    '/question/default',  to: 'yokyu#question_default'
  delete '/question',          to: 'yokyu#question_destroy'
  
  get    '/answer/new',        to: 'yokyu#answer_new'
  post   '/answer/new',        to: 'yokyu#answer_create'
  get    '/answer/edit',       to: 'yokyu#answer_edit'
  post   '/answer/edit',       to: 'yokyu#answer_update'
  delete '/answer',            to: 'yokyu#answer_destroy'
  
  get    '/yokyu',             to: 'yokyu#index'
  post   '/learn',             to: 'yokyu#learn'
  post   '/write',             to: 'yokyu#write'
  get    '/senconfirm',        to: 'yokyu#confirm'
  post   '/senconfirm',        to: 'yokyu#confirmed'
  get    '/yokyufile',         to: 'yokyu#filelist'
  delete '/file',              to: 'yokyu#file_destroy'

  devise_for :users
  root 'pages#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :companies, only: [:show, :edit, :destroy]

end
