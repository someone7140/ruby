Rails.application.routes.draw do
  post '/auth_by_google_auth_code', to: 'auth#auth_by_google_auth_code'
end
