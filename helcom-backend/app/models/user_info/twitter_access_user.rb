# frozen_string_literal: true

module UserInfo
  # Twitterリンクを踏んだユーザ履歴
  class TwitterAccessUser
    include Mongoid::Document
    field :user_id, type: String
    field :access_at, type: DateTime
    validates :user_id, presence: true
    validates :access_at, presence: true
  end
end
