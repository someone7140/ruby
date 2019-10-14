class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword
  field :_id, type: Integer
  field :email, type: String
  field :name, type: String
  field :password_digest, type: String
  index({ email: 1 }, unique: true)
  has_secure_password
end
