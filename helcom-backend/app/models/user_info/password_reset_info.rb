# frozen_string_literal: true

module UserInfo
  # PasswordResetInfo
  class PasswordResetInfo
    include Mongoid::Document
    field :token, type: String
    field :expired_at, type: DateTime
    embedded_in :user
    validates :token, presence: true
    validates :expired_at, presence: true
  end
end
