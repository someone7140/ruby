# frozen_string_literal: true

# UserAccount
class UserAccount
  include Mongoid::Document

  field :_id, type: String, overwrite: true
  field :email, type: String
  field :password, type: String
  field :gmail, type: String

  index({ email: 1, gmail: 1 }, unique: true)
end
