# frozen_string_literal: true

module Chat
  # グループチャットに関わるコントローラー
  class GroupChatController < ApplicationController
    include ChatService
    include ResponseConstants

    before_action :logged_in_user

    # チャットログの追記
    def add_group_chat_log
      success_flg = GroupChatService.add_chat_log(
        add_group_chat_log_param[:chat_contents_id],
        session[:user_id],
        add_group_chat_log_param[:contents],
        add_group_chat_log_param[:category]
      )
      if success_flg
        render json: { status: HTTP_STATUS_200 }
      else
        render json: { status: HTTP_STATUS_400 }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def add_group_chat_log_param
      params.require(:add_group_chat_log).permit(:chat_contents_id, :category, :contents)
    end

    # チャットログの取得
    def get_group_chat_log
      chat_logs = GroupChatService.get_chat_log(
        params[:category],
        params[:skip].to_i,
        params[:limit].to_i
      )
      render json: { status: HTTP_STATUS_200, chat_logs: chat_logs }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end
  end
end
