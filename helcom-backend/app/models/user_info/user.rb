# frozen_string_literal: true

module UserInfo
  # User
  class User
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActiveModel::SecurePassword
    include UserConstants

    field :_id, type: String, overwrite: true
    field :status, type: String
    field :role, type: String
    field :email, type: String
    field :twitter_id, type: String
    field :password_digest, type: String
    field :login_count, type: Integer
    field :last_login_at, type: DateTime
    embeds_one :profile
    embeds_one :email_auth_info
    embeds_one :password_reset_info
    embeds_many :twitter_access_users
    embeds_many :instagram_access_users
    embeds_many :facebook_access_users
    field :block_user_ids, type: Array
    index({ email: 1, twitter_id: 1 }, unique: true)
    index 'twitter_access_users.user_id' => 1
    index 'instagram_access_users.user_id' => 1
    index 'facebook_access_users.user_id' => 1
    index 'block_user_ids' => 1
    has_secure_password
    validates :_id, length: { minimum: 6 }, presence: true
    validates :status, presence: true, inclusion: { in: [
      STATUS_ACTIVE, STATUS_SUSPEND, STATUS_CONFIRMING
    ] }
    validates :role, presence: true, inclusion: { in: [ROLE_ADMIN, ROLE_USER] }

    def self.get_user_collection
      db = Mongoid::Clients.default
      db[:user_info_users]
    end
  end
end
