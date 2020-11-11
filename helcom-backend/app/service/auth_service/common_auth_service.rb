# frozen_string_literal: true

module AuthService
  # 認証用の共通サービス
  class CommonAuthService
    include ChatService
    include CommonService
    include PostInfo
    include PostService
    include UserInfo
    include UserService

    # ユーザのステータス変更
    def self.change_user_status(user_id, change_status)
      user_collection = User.get_user_collection
      user_collection.update_one(
        { '_id' => user_id },
        { '$set' => {
          'status' => change_status
        } }
      )
    end

    # ユーザの削除
    def self.user_delete(user_id)
      # 通報の削除
      post_whistle_find_result = PostWhistle.where(post_owner_user_id: user_id).or(whistle_send_user_id: user_id)
      post_whistle_find_result.delete unless post_whistle_find_result.empty?
      # 記事投稿の削除
      post_find_result = Post.where(user_id: user_id)
      post_find_result.delete unless post_find_result.empty?
      # 投稿アクセス履歴の削除
      PostManagementService.delete_post_user_count(user_id)
      # SNSアクセス履歴の削除
      UserProfileService.delete_sns_user_count(user_id)
      # グループチャットのユーザIDを空にする
      GroupChatService.update_empty_user_id(user_id)
      # ブロックリストの登録を削除する
      PersonalChatService.delete_block_registered_other_user(user_id)
      # イメージ画像の削除
      user_find_result = User.where(_id: user_id).only(
        :_id,
        'profile.image_url'
      )
      unless user_find_result.empty?
        user_info = user_find_result[0]
        StorageService.delete_image_file_by_url(user_info.profile.image_url)
      end
      # ユーザの削除
      user_find_result_for_delete = User.where(_id: user_id)
      user_find_result_for_delete.delete unless user_find_result.empty?
    end

    # ログイン履歴の更新
    def self.login_history_update(user)
      user_collection = User.get_user_collection
      user_collection.update_one(
        { '_id' => user._id },
        { '$set' => {
          'login_count' => user.login_count.nil? ? 1 : user.login_count + 1,
          'last_login_at' => Time.now.utc
        } }
      )
    end
  end
end
