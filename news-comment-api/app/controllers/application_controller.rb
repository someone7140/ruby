class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  http_basic_authenticate_with :name => ENV['BASIC_AUTH_USERNAME'], :password => ENV['BASIC_AUTH_PASSWORD'] if Rails.env == "staging"
end
