# frozen_string_literal: true

module Chat
  # グループチャットに関わるコントローラー
  class PersonalChatController < ApplicationController
    include ChatService
    include ResponseConstants

    before_action :logged_in_user

    # ブロックユーザの追加
    def add_block_user
      success_flg = PersonalChatService.add_block_user(
        session[:user_id],
        block_user_param[:block_user_id]
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

    # ブロックユーザの削除
    def delete_block_user
      PersonalChatService.delete_block_user(
        session[:user_id],
        block_user_param[:block_user_id]
      )
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def block_user_param
      params.require(:block_user_param).permit(:block_user_id)
    end

    # ブロックユーザの取得（自分のみ）
    def get_block_users_own
      block_users = PersonalChatService.get_block_users_own(
        session[:user_id]
      )
      render json: { status: HTTP_STATUS_200, block_users: block_users }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    # ブロックユーザの取得（双方）
    def get_block_users_each
      block_users = PersonalChatService.get_block_users_each(
        session[:user_id]
      )
      render json: { status: HTTP_STATUS_200, block_users: block_users }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    # 個別チャットログと部屋の削除
    def delete_personal_chat_log_and_room
      PersonalChatService.delete_fire_base_all_chat_log(
        'personal_chat_' + delete_personal_chat_log_and_room_param[:room_id]
      )
      PersonalChatService.delete_fire_base_room_doc(
        'room_personal_chat_' + delete_personal_chat_log_and_room_param[:category],
        delete_personal_chat_log_and_room_param[:room_doc_id]
      )
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def delete_personal_chat_log_and_room_param
      params.require(:delete_personal_chat_log_and_room_param).permit(:room_id, :room_doc_id, :category)
    end

    # 部屋の削除
    def delete_personal_chat_room
      PersonalChatService.delete_fire_base_room_doc(
        'room_personal_chat_' + delete_personal_chat_room_param[:category],
        delete_personal_chat_room_param[:room_doc_id]
      )
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def delete_personal_chat_room_param
      params.require(:delete_personal_chat_room_param).permit(:room_doc_id, :category)
    end

    # 個別チャットログの削除
    def delete_personal_chat_log
      PersonalChatService.delete_fire_base_all_chat_log('personal_chat_' + delete_personal_chat_log_param[:room_id])
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def delete_personal_chat_log_param
      params.require(:delete_personal_chat_log_param).permit(:room_id)
    end
  end
end
