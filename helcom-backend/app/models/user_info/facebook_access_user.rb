# frozen_string_literal: true

module UserInfo
  # Facebookリンクを踏んだユーザ履歴
  class FacebookAccessUser
    include Mongoid::Document
    field :user_id, type: String
    field :access_at, type: DateTime
    validates :user_id, presence: true
    validates :access_at, presence: true
  end
end
