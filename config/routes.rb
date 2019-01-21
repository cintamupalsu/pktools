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
  
  get    '/yokyu',              to: 'yokyu#index'
  post   '/learn',              to: 'yokyu#learn'
  post   '/write',              to: 'yokyu#write'
  get    '/senconfirm',         to: 'yokyu#confirm'
  post   '/senconfirm',         to: 'yokyu#confirmed'
  get    '/yokyu_onaji',        to: 'yokyu#onaji'
  get    '/yokyu_chigau',       to: 'yokyu#chigau'
  get    '/yokyufile',          to: 'yokyu#filelist'
  delete '/file',               to: 'yokyu#file_destroy'
  get    '/manage_sentences',   to: 'yokyu#senmanage'
  get    '/betsu',              to: 'yokyu#betsu'
  get    '/attach',             to: 'yokyu#attach'
  get    '/attached',           to: 'yokyu#attached'
  post   '/sentence_filter',    to: 'yokyu#sentence_filter'
  get    '/sentence_filter',    to: 'yokyu#attach'
  delete '/betsu',              to: 'yokyu#delete_sentence'
  get    '/yokyu_download',     to: 'yokyu#download'
  get    '/yokyu_download_file',to: 'yokyu#download_file'
  get    '/yokyu/documentation',to: 'yokyu#documentation'
  get    '/sentence',           to: 'yokyu#sentence'
  post   '/watson_update_path', to: 'yokyu#watson_update'
  post   '/sentence_search',    to: 'yokyu#sentence_search'
  get    '/sentence_search',    to: 'yokyu#senmanage'

  get    '/user_management',    to: 'pages#user_management'
  get    '/user_statistic',     to: 'pages#user_statistic'
  get    '/downgrade',          to: 'pages#downgrade'
  get    '/detach',             to: 'pages#detach'
  get    '/activate',           to: 'pages#activate'
  get    '/promote',            to: 'pages#promote'

  devise_for :users
  root 'pages#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :companies, only: [:show, :edit, :destroy]

end
