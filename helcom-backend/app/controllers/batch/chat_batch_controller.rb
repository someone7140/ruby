# frozen_string_literal: true

require 'active_support/time'

module Batch
  # チャットのバッチ処理
  class ChatBatchController < ApplicationController
    include ChatService
    include ResponseConstants

    # firebase過去チャットログのクリア処理
    def firebase_past_log_clear
      # グループチャットの過去ログを削除
      ChatBatchService.clear_fire_store_past_log(60.minutes, 'group_chat')
      # 時間が過ぎた一対一チャットの部屋を削除
      ChatBatchService.clear_fire_store_past_log(120.minutes, 'room_personal_chat')
      # 更新がされていない一対一チャットのメッセージを削除
      ChatBatchService.clear_fire_store_past_personal_chat(60.minutes)
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end
  end
end
