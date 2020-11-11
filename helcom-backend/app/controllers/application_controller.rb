# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ResponseConstants
  include UserConstants
  include UserService

  if Rails.env == 'staging'
    http_basic_authenticate_with name: ENV['BASIC_AUTH_USERNAME'], password: ENV['BASIC_AUTH_PASSWORD']
  end

  # ログインユーザのチェック
  def logged_in_user
    render json: { status: HTTP_STATUS_401 } if session[:user_id].nil?
  end

  # 管理者ユーザのチェック
  def admin_logged_in_user
    user_info = UserProfileService.get_own_basic_info(session[:user_id])
    render json: { status: HTTP_STATUS_401 } if user_info.nil? || user_info.role != ROLE_ADMIN
  end
end
