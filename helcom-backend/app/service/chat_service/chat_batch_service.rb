# frozen_string_literal: true

require 'active_support/time'
require 'google/cloud/firestore'

module ChatService
  # チャット用のバッチサービス
  class ChatBatchService
    # firestoreの過去ログを指定した時間より前の削除
    def self.clear_fire_store_past_log(past_minutes, collection_name)
      # 削除対象時間（これより前）
      past_time = Time.now.in_time_zone('Tokyo') - past_minutes
      # firestoreオブジェクトの取得
      firestore = Google::Cloud::Firestore.new
      collectios = firestore.list_collections
      collectios.each do |c|
        col_name = collection_name_from_path(c.path)
        next unless col_name.start_with?(collection_name)

        # 削除対象のdoc配列格納用
        doc_array = []
        # コレクションの取得
        chat_log_ref = firestore.col col_name
        query = chat_log_ref.where 'created_at', '<', past_time
        query.get do |g|
          # 対象のdocを配列に格納
          doc_array.push g.ref
        end
        # 500個までしか削除できないことを考慮
        document_index = 0
        batch_index = 0
        # バッチで削除
        while document_index < doc_array.size
          firestore.batch do |b|
            # 501個目のindexで中断
            break if batch_index == 500

            b.delete doc_array[document_index]
            document_index += 1
            batch_index += 1
          end
          batch_index = 0
        end
      end
    end

    # 指定した時間より後のメッセージがなければコレクション削除
    def self.clear_fire_store_past_personal_chat(past_minutes)
      # 削除対象時間（これより後のものが無ければ削除）
      past_time = Time.now.in_time_zone('Tokyo') - past_minutes
      # firestoreオブジェクトの取得
      firestore = Google::Cloud::Firestore.new
      collectios = firestore.list_collections
      collectios.each do |c|
        col_name = collection_name_from_path(c.path)
        next unless col_name.start_with?('personal_chat')

        # コレクションの取得
        personal_chat_log_ref = firestore.col col_name
        query = personal_chat_log_ref.where 'created_at', '>', past_time
        query_result = query.get
        # 1件もない場合
        if query_result.nil? || query_result.count.zero?
          # コレクションを全削除
          PersonalChatService.delete_fire_base_all_chat_log(col_name)
        end
      end
    end

    # firestoreのパスからコレクション名を取得
    def self.collection_name_from_path(path_name)
      slash_last_index = path_name.rindex('/')
      path_name.slice(slash_last_index + 1, path_name.length - slash_last_index - 1)
    end
  end
end
