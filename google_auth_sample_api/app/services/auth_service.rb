# frozen_string_literal: true

require 'googleauth'
require 'google/apis/oauth2_v2'

# 認証用のサービス
class AuthService
  @scopes = %w[email profile openid]
  # GoogleのOauthクライアント設定画面からダウンロードする認証用のjson
  @client_id = Google::Auth::ClientId.from_file(ENV.fetch('GOOGLE_AUTH_SECRETS_FILE_PATH'))

  # googleの認証コードによる認証
  def self.auth_by_google_auth_code(auth_code)
    authorizer = Google::Auth::UserAuthorizer.new(
      @client_id,
      @scopes,
      nil, # 認証情報を特に記録しないのでnil
      ENV.fetch('FRONTEND_URL') # GoogleのOauthクライアント設定画面の承認済みのJavaScript生成元で許可したURL
    )
    credentials = authorizer.get_credentials_from_code(code: auth_code)
    # プロフィールの取得
    oauth = Google::Apis::Oauth2V2::Oauth2Service.new.tap do |service|
      service.authorization = credentials
    end
    user_info = oauth.get_userinfo_v2
    puts(user_info.name)
  end

  # googleのリフレッシュトークンによる認証
  def self.auth_by_google_refresh_token(setting_refresh_token)
    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: @client_id.id,
      client_secret: @client_id.secret,
      refresh_token: setting_refresh_token,
      scope: @scopes
    )
    credentials.fetch_access_token!
    credentials
  end
end
