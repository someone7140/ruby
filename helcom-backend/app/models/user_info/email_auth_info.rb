# frozen_string_literal: true

module UserInfo
  # EmailAuth
  class EmailAuthInfo
    include Mongoid::Document
    field :temp_email, type: String
    field :token, type: String
    field :expired_at, type: DateTime
    embedded_in :user
    validates :temp_email, presence: true
    validates :token, presence: true
    validates :expired_at, presence: true
  end
end
