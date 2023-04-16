# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  # ログインのチェック
  def login_check
    authenticate_or_request_with_http_token do |token, _|
      payload = CommonService.decode_jwt(token)
      session[:auth_payload] = payload
      true
    rescue
      false
    end
  end
end
