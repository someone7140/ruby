# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :auth do
    post '/regist_email_user', to: 'email_auth#regist_email_user'
    post '/change_email', to: 'email_auth#change_email'
    post '/auth_email_user', to: 'email_auth#auth_email_user'
    post '/email_login', to: 'email_auth#email_login'
    post '/auth_password_change', to: 'email_auth#auth_password_change'
    post '/password_reset_send', to: 'email_auth#password_reset_send'
    post '/password_reset_regist', to: 'email_auth#password_reset_regist'

    post '/logout', to: 'common_auth#logout'
    post '/user_suspend', to: 'common_auth#user_suspend'
    post '/user_cancel', to: 'common_auth#user_cancel'
  end

  namespace :batch do
    post '/firebase_log_clear', to: 'chat_batch#firebase_past_log_clear'
  end

  namespace :chat do
    post '/add_group_chat_log', to: 'group_chat#add_group_chat_log'
    get '/get_group_chat_log', to: 'group_chat#get_group_chat_log'

    post '/add_block_user', to: 'personal_chat#add_block_user'
    post '/delete_block_user', to: 'personal_chat#delete_block_user'
    get '/get_block_users_own', to: 'personal_chat#get_block_users_own'
    get '/get_block_users_each', to: 'personal_chat#get_block_users_each'
    post '/delete_personal_chat_log_and_room', to: 'personal_chat#delete_personal_chat_log_and_room'
    post '/delete_personal_chat_room', to: 'personal_chat#delete_personal_chat_room'
    post '/delete_personal_chat_log', to: 'personal_chat#delete_personal_chat_log'
  end

  namespace :common do
    get '/master', to: 'master#get_master'
    post '/send_inquiry', to: 'inquiry#send_inquiry'
  end

  namespace :post do
    post '/post_create', to: 'post#post_create'
    post '/admin_post_create', to: 'post#admin_post_create'
    post '/post_user_count', to: 'post#post_user_count'
    post '/post_edit', to: 'post#post_edit'
    post '/post_delete', to: 'post#post_delete'
    get '/refer_own_post/:post_id', to: 'post#refer_own_post_info'
    get '/refer_user_posts/:user_id', to: 'post#refer_user_posts'
    get '/refer_admin_posts', to: 'post#refer_admin_posts'
    get '/refer_all_users_posts', to: 'post#refer_all_users_posts'

    post '/post_whistle_send', to: 'post_whistle#post_whistle_send'
    get '/admin_post_whistle_list', to: 'post_whistle#admin_post_whistle_list'
  end

  namespace :user_profile do
    post '/profile_regist', to: 'profile#profile_regist'
    get '/profile_refer/:user_id', to: 'profile#profile_refer'
    post '/sns_user_count', to: 'profile#sns_user_count'
  end
end
