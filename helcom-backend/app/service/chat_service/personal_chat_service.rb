# frozen_string_literal: true

require 'google/cloud/firestore'

module ChatService
  # 個別チャット関連のサービス
  class PersonalChatService
    include ChatInfo
    include UserInfo

    # ブロックユーザの追加
    def self.add_block_user(own_user_id, block_user_id)
      user_find_result = User.where(_id: block_user_id).only(:_id)
      if user_find_result.empty?
        false
      else
        user_collection = User.get_user_collection
        user_collection.update_one(
          { '_id' => own_user_id },
          { '$push' => {
            'block_user_ids' => block_user_id
          } }
        )
        true
      end
    end

    # ブロックユーザの削除
    def self.delete_block_user(own_user_id, delete_block_user_id)
      User.where({ '_id' => own_user_id }).update_all(
        { '$pull' => { 'block_user_ids' => delete_block_user_id } }
      )
    end

    # ブロックユーザの削除（退会用）
    def self.delete_block_registered_other_user(delete_block_user_id)
      User.update_all(
        { '$pull' => { 'block_user_ids' => delete_block_user_id } }
      )
    end

    # ブロックユーザの取得（自分のみ）
    def self.get_block_users_own(own_user_id)
      own_user_find_result = User.where(_id: own_user_id).only(:_id, :block_user_ids)
      if own_user_find_result[0].block_user_ids.nil?
        []
      else
        own_user_find_result[0].block_user_ids.sort
      end
    end

    # ブロックユーザの取得（双方）
    def self.get_block_users_each(own_user_id)
      # 自分がブロックされているユーザのリスト
      own_blocked_users = User.where(:block_user_ids.in => [own_user_id]).only(:_id).map(&:_id)
      # 自分のブロックユーザ配列と結合して重複排除
      own_blocked_users.push(get_block_users_own(own_user_id)).flatten.uniq
    end

    # 指定したコレクションのチャットログを全削除
    def self.delete_fire_base_all_chat_log(col_name)
      # firestoreオブジェクトの取得
      firestore = Google::Cloud::Firestore.new
      # 削除対象のdoc配列格納用
      doc_array = []
      query = firestore.col col_name
      query.get do |p|
        # 対象のdocを配列に格納
        doc_array.push p.ref
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

    # 指定した部屋のdocを削除
    def self.delete_fire_base_room_doc(col_name, doc_id)
      # firestoreオブジェクトの取得
      firestore = Google::Cloud::Firestore.new
      room_doc_ref = firestore.doc col_name + '/' + doc_id
      room_doc_ref.delete
    end
  end
end
