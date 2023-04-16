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
    oauth.get_userinfo_v2
  end

  # gmailをキーにアカウント取得
  def self.get_user_account_by_gmail(gmail)
    UserAccountRepository.get_user_account_by_gmail(gmail)
  end

  # gmailをキーにアカウント作成
  def self.create_user_account_by_gmail(gmail)
    id = CommonService.generate_uid
    user_account = UserAccountRepository.create_user_account_by_gmail(id, gmail, nil, nil)
    make_user_response(user_account)
  end

  # userのレスポンス情報を作成
  def self.make_user_response(user_account)
    gmail = user_account.gmail
    email = user_account.email
    payload = {
      id: user_account._id,
      gmail:,
      email:
    }
    # トークンの期限は3ヶ月
    exp = Time.now.to_i + 90 * 24 * 60 * 60
    token = CommonService.encode_jwt(payload, exp)
    {
      token:,
      displayAccount: gmail.nil? ? email : gmail
    }
  end
end
