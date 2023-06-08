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
  post 'novel/delete_novel', to: 'novel#delete_novel'
  # novel_setting系のパス
  get 'novel/setting/setting_list', to: 'novel_setting#setting_list'
  get 'novel/setting/setting_by_id', to: 'novel_setting#setting_by_id'
  post 'novel/setting/create_novel', to: 'novel_setting#create_setting'
  post 'novel/setting/update_setting_name', to: 'novel_setting#update_setting_name'
  post 'novel/setting/update_settings', to: 'novel_setting#update_settings'
  # novel_contents系のパス
  post 'novel/contents/update_contents', to: 'novel_contents#update_contents'
  get 'novel/contents/contents_by_novel_id', to: 'novel_contents#contents_by_novel_id'
end
