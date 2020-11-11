# frozen_string_literal: true

module Auth
  # メール認証に関わるコントローラー
  class EmailAuthController < ApplicationController
    include AuthService
    include CommonService
    include ResponseConstants
    include UserConstants

    before_action :logged_in_user, only: %i[auth_password_change]

    # メール認証登録
    def regist_email_user
      # ユーザの登録とメール送信
      new_user = EmailAuthService.get_regist_email_user(
        email_regist_param[:id],
        email_regist_param[:email],
        email_regist_param[:password]
      )
      if new_user.nil?
        render json: { status: HTTP_STATUS_400 }
      else
        new_user.save!
        # メール送信
        MailService.send_email_regist_mail(
          new_user._id,
          new_user.email,
          new_user.email_auth_info.token,
          'regist'
        )
        render json: { status: HTTP_STATUS_200 }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def email_regist_param
      params.require(:email_register).permit(:id, :email, :password)
    end

    # メール変更の認証登録
    def change_email
      # 変更情報の登録
      token = EmailAuthService.email_change_and_return_token(
        email_change_param[:id],
        email_change_param[:email]
      )
      if token.nil?
        render json: { status: HTTP_STATUS_403 }
      else
        # メール送信
        MailService.send_email_regist_mail(
          email_change_param[:id],
          email_change_param[:email],
          token,
          'change'
        )
        render json: { status: HTTP_STATUS_200 }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def email_change_param
      params.require(:email_change).permit(:id, :email)
    end

    # 登録したメールの認証
    def auth_email_user
      if auth_email_param[:category] == 'regist'
        # 認証ユーザの取得
        authenticated_user = EmailAuthService.get_authenticated_email_user(
          auth_email_param[:id],
          auth_email_param[:token],
          auth_email_param[:password]
        )
        if authenticated_user.nil?
          render json: { status: HTTP_STATUS_401 }
        else
          authenticated_user.save!
          # セッションにユーザIDを入れる
          session[:user_id] = auth_email_param[:id]
          render json: { status: HTTP_STATUS_200 }
        end
      else
        success_flg = EmailAuthService.email_change_authentication(
          auth_email_param[:id],
          auth_email_param[:token],
          auth_email_param[:password]
        )
        if success_flg
          render json: { status: HTTP_STATUS_200 }
        else
          render json: { status: HTTP_STATUS_401 }
        end
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def auth_email_param
      params.require(:auth_email).permit(:id, :token, :password, :category)
    end

    # eメールでユーザをチェックして問題なければユーザ情報を返す
    def email_login
      user = EmailAuthService.get_user_by_email(email_login_param[:email])
      if user.nil?
        render json: { status: HTTP_STATUS_400 }
      elsif user.status != STATUS_ACTIVE
        render json: { status: HTTP_STATUS_403 }
      elsif !user.authenticate(email_login_param[:password])
        render json: { status: HTTP_STATUS_401 }
      else
        # ログインの履歴記録
        CommonAuthService.login_history_update(user)
        session[:user_id] = user._id
        render json: { status: HTTP_STATUS_200, user: {
          user_id: user._id,
          name: user.profile.nil? ? '' : user.profile.name,
          image_url: user.profile.nil? ? '' : user.profile.image_url,
          role: user.role
        } }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def email_login_param
      params.require(:email_login).permit(:email, :password)
    end

    # パスワードの変更
    def auth_password_change
      EmailAuthService.change_password(session[:user_id], password_change_param[:password])
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def password_change_param
      params.require(:password_change).permit(:password)
    end

    # パスワードリセット申請
    def password_reset_send
      user_info = EmailAuthService.send_password_reset(password_reset_send_param[:email])
      if !user_info.nil?
        # メール送信
        MailService.password_reset_regist_mail(
          user_info[:user_id],
          password_reset_send_param[:email],
          user_info[:token]
        )
        render json: { status: HTTP_STATUS_200 }
      else
        render json: { status: HTTP_STATUS_400 }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def password_reset_send_param
      params.require(:password_reset_send).permit(:email)
    end

    # パスワードリセット登録
    def password_reset_regist
      success_flg = EmailAuthService.regist_password_reset(
        password_reset_regist_param[:user_id],
        password_reset_regist_param[:token],
        password_reset_regist_param[:password]
      )
      render json: success_flg ? { status: HTTP_STATUS_200 } : { status: HTTP_STATUS_400 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def password_reset_regist_param
      params.require(:password_reset_regist).permit(:user_id, :token, :password)
    end
  end
end
