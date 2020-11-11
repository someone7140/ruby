# frozen_string_literal: true

module UserInfo
  # instagramリンクを踏んだユーザ履歴
  class InstagramAccessUser
    include Mongoid::Document
    field :user_id, type: String
    field :access_at, type: DateTime
    validates :user_id, presence: true
    validates :access_at, presence: true
  end
end
