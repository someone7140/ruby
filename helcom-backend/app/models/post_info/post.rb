# frozen_string_literal: true

module PostInfo
  # Post
  class Post
    include Mongoid::Document
    include Mongoid::Timestamps
    include MasterConstants
    include UserConstants

    field :_id, type: String, overwrite: true
    field :user_id, type: String
    field :title, type: String
    field :url, type: String
    field :category, type: String
    field :open_flg, type: Boolean
    field :post_role, type: String
    embeds_many :post_access_users
    embeds_many :post_whistles
    embeds_one :ogp
    index({ user_id: 1 })
    index({ category: 1 })
    index({ open_flg: 1 })
    index({ post_role: 1 })
    index 'post_access_users.user_id' => 1
    index 'post_access_users.access_at' => -1
    index 'post_whistles.whistle_at' => -1
    validates :_id, presence: true
    validates :user_id, presence: true
    validates :title, presence: true
    validates :url, presence: true
    validates :category, presence: true, inclusion: { in: POST_CATEGORY_LIST.map { |d| d[:key] } }
    validates :open_flg, presence: true
    validates :post_role, presence: true, inclusion: { in: [ROLE_ADMIN, ROLE_USER] }

    def self.get_post_collection
      db = Mongoid::Clients.default
      db[:post_info_posts]
    end
  end
end
