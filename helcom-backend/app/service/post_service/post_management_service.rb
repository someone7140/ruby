# frozen_string_literal: true

module PostService
  # 記事の管理に関するサービス
  class PostManagementService
    include CommonService
    include PostInfo
    include UserConstants

    # 記事を踏んだユーザのカウント
    def self.add_post_user_count(post_id, user_id)
      post_collection = Post.get_post_collection
      find_user_access = post_collection.aggregate(
        [
          { '$match' => { '_id' => post_id } },
          { '$match' => { 'user_id' => { '$ne' => user_id } } }, # 自身の記事は省く
          { '$match' => { 'post_access_users.user_id' => { '$ne' => user_id } } }, # 既にそのユーザが踏んだ履歴がないか
          { '$group' => {
            _id: '$_id'
          } }
        ]
      ).to_a
      unless find_user_access.empty?
        add_access = {
          'post_access_users' => {
            'user_id' => user_id,
            'access_at' => Time.now.utc
          }
        }
        post_collection.update_one(
          { '_id' => post_id },
          { '$push' => add_access }
        )
      end
    end

    # 記事を踏んだユーザの削除（退会時）
    def self.delete_post_user_count(user_id)
      Post.where({ 'post_access_users.user_id' => user_id }).update_all(
        { '$pull' => { 'post_access_users' => { 'user_id' => user_id } } }
      )
    end

    # 通報を送信
    def self.send_post_whistle(post_id, contents, whistle_send_user_id)
      post_find = Post.where(_id: post_id).only(:user_id)
      if !post_find.empty?
        post_whistle = PostWhistle.new(
          post_id: post_id,
          post_owner_user_id: post_find[0].user_id,
          whistle_send_user_id: whistle_send_user_id,
          contents: contents,
          whistle_at: Time.now.utc
        )
        if post_whistle.valid?
          post_whistle.save!
          true
        else
          false
        end
      else
        false
      end
    end

    # 記事IDを指定した通報の削除
    def self.delete_post_whistle_by_post_id(post_id)
      post_whistle_find_result = PostWhistle.where(post_id: post_id)
      post_whistle_find_result.delete unless post_whistle_find_result.empty?
    end

    # 通報一覧の取得
    def self.get_whistle_list(limit)
      post_whistle_collection = PostWhistle.get_post_whistle_collection
      post_whistle_collection.aggregate(
        [
          { "$lookup": {
            "from": 'post_info_posts',
            "localField": 'post_id',
            "foreignField": '_id',
            "as": 'post_info'
          } },
          { '$project' => {
            post_owner_user_id: 1,
            whistle_send_user_id: 1,
            contents: 1,
            whistle_at: 1,
            "post_info.title": 1,
            "post_info.url": 1
          } },
          { '$sort' => { 'whistle_at' => -1 } },
          { '$limit' => limit }
        ]
      ).to_a.map do |p|
        post_info = p[:post_info][0]
        {
          title: post_info[:title],
          url: post_info[:url],
          post_owner_user_id: p[:post_owner_user_id],
          whistle_send_user_id: p[:whistle_send_user_id],
          contents: p[:contents],
          whistle_at: p[:whistle_at]
        }
      end
    end
  end
end
