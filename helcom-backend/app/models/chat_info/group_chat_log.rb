# frozen_string_literal: true

module ChatInfo
  # グループチャットのログ
  class GroupChatLog
    include Mongoid::Document
    include Mongoid::Timestamps
    include MasterConstants
    include UserConstants

    field :_id, type: String, overwrite: true
    field :user_id, type: String
    field :contents, type: String
    field :delete_flg, type: Boolean
    field :category, type: String
    index({ user_id: 1 })
    index({ category: 1 })
    index 'created_at' => -1
    validates :_id, presence: true
    validates :contents, presence: true
    validates :delete_flg, presence: true
    validates :category, presence: true, inclusion: { in: CHAT_CATEGORY_LIST.map { |d| d[:key] } }

    def self.group_chat_log_collection
      db = Mongoid::Clients.default
      db[:chat_info_group_chat_logs]
    end
  end
end
