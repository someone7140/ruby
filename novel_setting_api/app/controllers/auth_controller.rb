# frozen_string_literal: true

# 認証に関わるコントローラー
class AuthController < ApplicationController
  before_action :login_check, only: %i[auth_by_token]

  # トークンによる認証
  def auth_by_token
    auth_payload = session[:auth_payload]
    render status: :ok, json: {
      displayAccount: if auth_payload['gmail'].nil?
                        auth_payload['email']
                      else
                        auth_payload['gmail']
                      end
    }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end

  # google認証コードによる会員登録
  def register_by_google_auth_code
    param! :authCode, String, required: true, blank: false

    google_auth_info = AuthService.auth_by_google_auth_code(params[:authCode])
    gmail = google_auth_info.email
    # 該当のユーザが登録済みか
    regsitered_user = AuthService.get_user_account_by_gmail(gmail)
    if regsitered_user.nil?
      # 会員登録
      result = AuthService.create_user_account_by_gmail(gmail)
      render status: :ok, json: result
    else
      render status: :method_not_allowed
    end
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end

  # google認証コードによるログイン
  def login_by_google_auth_code
    param! :authCode, String, required: true, blank: false

    google_auth_info = AuthService.auth_by_google_auth_code(params[:authCode])
    gmail = google_auth_info.email
    # 該当のユーザが登録済みか
    regsitered_user = AuthService.get_user_account_by_gmail(gmail)
    if regsitered_user.nil?
      render status: :unauthorized
    else
      render status: :ok, json: AuthService.make_user_response(regsitered_user)
    end
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end
end
