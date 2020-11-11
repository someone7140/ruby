# frozen_string_literal: true

module PostInfo
  # 投稿の通報
  class PostWhistle
    include Mongoid::Document
    field :post_id, type: String
    field :post_owner_user_id, type: String
    field :whistle_send_user_id, type: String
    field :contents, type: String
    field :whistle_at, type: DateTime
    validates :post_owner_user_id, presence: true
    validates :whistle_send_user_id, presence: true
    validates :contents, presence: true
    validates :whistle_at, presence: true
    index({ post_id: 1 })
    index({ post_owner_user_id: 1 })
    index({ whistle_send_user_id: 1 })
    index({ whistle_at: -1 })

    def self.get_post_whistle_collection
      db = Mongoid::Clients.default
      db[:post_info_post_whistles]
    end
  end
end
