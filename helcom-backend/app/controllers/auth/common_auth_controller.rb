# frozen_string_literal: true

module Auth
  # 認証方法共通のコントローラー
  class CommonAuthController < ApplicationController
    include AuthService
    include ResponseConstants
    include UserConstants

    before_action :logged_in_user, only: %i[logout]
    before_action :admin_logged_in_user, only: [:user_suspend]

    # ログアウト
    def logout
      session[:user_id] = nil
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    # ユーザ凍結
    def user_suspend
      CommonAuthService.change_user_status(user_suspend_param[:user_id], UserConstants::STATUS_SUSPEND)
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def user_suspend_param
      params.require(:user_suspend).permit(:user_id)
    end

    # 退会
    def user_cancel
      CommonAuthService.user_delete(session[:user_id])
      session[:user_id] = nil
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end
  end
end
