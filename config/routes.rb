Rails.application.routes.draw do
  
  get    '/reports',            to: 'reports#index'
  post   '/userkpi',            to: 'reports#userkpi'
  post   '/userkgi',            to: 'reports#postuserkgi'
  get    '/userkgi',            to: 'reports#userkgi'
  get    '/kenteidailyreport',  to: 'reports#user_k_dailyreport'
  post   '/kenteidailyreport',  to: 'reports#kenteidailyreport'
  
  get    '/briefs',             to: 'briefs#index'
  get    '/kentei',             to: 'briefs#kentei'
  post   '/kentei_excel',       to: 'briefs#kentei_excel'
  post   '/kenteidate',         to: 'briefs#kenteidate'
  get    '/kenteidate',         to: 'briefs#kentei'
  post   '/kenteidecided',      to: 'briefs#kenteidecided'
  post   '/kenteianswer',       to: 'briefs#kenteianswer'
  get    '/kenteiexam',         to: 'briefs#exam'
  get    '/newtest',            to: 'briefs#newtest'
  post   '/newtest',            to: 'briefs#createtest'
  post   '/choosemondai',       to: 'briefs#choosemondai'
  post   '/chooseuser',         to: 'briefs#chooseuser'
  get    '/managetest',         to: 'briefs#managetest'
  get    '/kenteitest',         to: 'briefs#kenteitest'
  post   '/kenteitest',         to: 'briefs#kenteitest'
  get    '/kenteiend',          to: 'briefs#kenteiend'
  get    '/edit_test',          to: 'briefs#edit_test'
  delete '/test_delete',        to: 'briefs#test_delete'
  get    '/manageexam',         to: 'briefs#manageexam'

  
  get    '/kpi',                to: 'kpi#index'
  get    '/kpi_assessement',    to: 'kpi#assessement'
  post   '/kpi_assessement',    to: 'kpi#assessement_record'
  post   '/kpi_assessement_cd', to: 'kpi#assessement_changedate'
  get    '/performance/new',    to: 'kpi#performance_new'
  post   '/performance/new',    to: 'kpi#performance_create'
  get    '/performance/index',  to: 'kpi#performance_index'
  get    '/performance',        to: 'kpi#performance_show'
  get    '/performance/edit',   to: 'kpi#performance_edit'
  post   '/performance/update', to: 'kpi#performance_update'
  get    '/performance/task',   to: 'kpi#performance_task'
  delete '/performance',        to: 'kpi#performance_delete'
  get    '/task/new',           to: 'kpi#perform_detail_new'
  post   '/task/new',           to: 'kpi#perform_detail_create'
  get    '/task/edit',          to: 'kpi#perform_detail_edit'
  post   '/task/update',        to: 'kpi#perform_detail_update'
  delete '/task',               to: 'kpi#perform_detail_delete'
  get    '/kpi/reports',        to: 'kpi#reports'
  post   '/kpi/reports',        to: 'kpi#reports_henkou'
  
  
  get    '/mpeg7',            to: 'mpeg7#index'
  post   '/image_saving',     to: 'mpeg7#image_saving'
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
  get    '/yokyu_rewrite', to: 'yokyu#rewrite'

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
