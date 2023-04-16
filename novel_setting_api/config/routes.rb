Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # 認証系のパス
  get 'auth/auth_by_token', to: 'auth#auth_by_token'
  post 'auth/register_by_google_auth_code', to: 'auth#register_by_google_auth_code'
  post 'auth/login_by_google_auth_code', to: 'auth#login_by_google_auth_code'
  # novel系のパス
  get 'novel/novel_list', to: 'novel#novel_list'
  post 'novel/create_novel', to: 'novel#create_novel'
  post 'novel/update_novel', to: 'novel#update_novel'
  # novel_setting系のパス
  post 'novel/setting/create_novel', to: 'novel_setting#create_novel'
end
