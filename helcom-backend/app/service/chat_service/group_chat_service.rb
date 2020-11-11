# frozen_string_literal: true

module ChatService
  # グループチャット関連のサービス
  class GroupChatService
    include ChatInfo

    # チャットログの追加
    def self.add_chat_log(chat_contents_id, user_id, contents, category)
      new_log = GroupChatLog.new(
        _id: chat_contents_id,
        user_id: user_id,
        contents: contents,
        delete_flg: false,
        category: category
      )
      if new_log.valid?
        new_log.save!
      else
        false
      end
    end

    # チャットログの取得
    def self.get_chat_log(category, skip_count, limit)
      collection = GroupChatLog.group_chat_log_collection
      chat_logs = collection.aggregate(
        [
          { '$match' => { 'category' => category } },
          { '$match' => { 'delete_flg' => false } },
          { "$lookup": {
            "from": 'user_info_users',
            "localField": 'user_id',
            "foreignField": '_id',
            "as": 'user_info'
          } },
          { '$project' => {
            _id: 1,
            contents: 1,
            created_at: 1,
            "user_info._id": 1,
            'user_info.profile.name': 1,
            'user_info.profile.image_url': 1
          } },
          { '$sort' => { 'created_at' => -1 } },
          { '$skip' => skip_count },
          { '$limit' => limit }
        ]
      ).to_a.map do |c|
        user_info = nil
        profile = nil
        unless c[:user_info].empty?
          user_info = c[:user_info][0]
          profile = user_info[:profile]
        end
        {
          message_id: c[:_id],
          contents: c[:contents],
          created_at: c[:created_at],
          user_id: !user_info.nil? ? user_info[:_id] : nil,
          user_name: !profile.nil? ? profile[:name] : nil,
          image_url: !profile.nil? ? profile[:image_url] : nil,
          type: 'success'
        }
      end
      # 作成日付の昇順でソートし直す
      chat_logs.sort do |a, b|
        a[:created_at] <=> b[:created_at]
      end
    end

    # ユーザIDを空にする（退会時）
    def self.update_empty_user_id(user_id)
      GroupChatLog.where({ 'user_id' => user_id }).update_all(
        { '$set' => {
          'user_id' => nil
        } }
      )
    end
  end
end
