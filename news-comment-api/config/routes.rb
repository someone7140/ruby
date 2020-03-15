Rails.application.routes.draw do
  get '/news', to: 'news#list'

  post '/loginFacebookUser', to: 'auth#facebookLogin'
  post '/emailLogin', to: 'auth#emailLogin'
  post '/logout', to: 'auth#logout'
  post '/registFacebookUser', to: 'auth#registFacebookUser'
  post '/registEmailUser', to: 'auth#registEmailUser'
  post '/authEmailUser', to: 'auth#authEmailUser'

  post '/editStudentProfile', to: 'student_profile#editStudentProfile'
  post '/deleteStudent', to: 'student_profile#deleteStudent'
  get '/getStudent', to: 'student_profile#getStudent'
  get '/getStudentForRef', to: 'student_profile#getStudentForRef'

  post '/editCompanyProfile', to: 'company_profile#editCompanyProfile'
  get '/getCompany', to: 'company_profile#getCompany'
  get '/getCompanyForRef', to: 'company_profile#getCompanyForRef'

  post '/registComment', to: 'comment#registComment'
  post '/deleteComment', to: 'comment#deleteComment'
  post '/getCommentByUrlAndUser', to: 'comment#getOwnCommentByUrl'
  post '/getCommentOtherUsers', to: 'comment#getCommentOtherUsers'
  get '/getCommentFilterUser', to:'comment#getCommentFilterUser'

  get '/getMessageUsers', to: 'message#getMessageUsers'
  get '/getMessages', to: 'message#getMessages'
  post '/postMessage', to: 'message#postMessage'
  post '/updateUnRead', to: 'message#updateUnRead'

  get '/master', to: 'master#list'
end
