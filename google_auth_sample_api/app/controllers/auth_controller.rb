# frozen_string_literal: true

# 認証に関わるコントローラー
class AuthController < ApplicationController
  # google認証コードによる認証
  def auth_by_google_auth_code
    param! :auth_code, String, required: true, blank: false

    AuthService.auth_by_google_auth_code(params[:auth_code])

    render status: :ok
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end
end
