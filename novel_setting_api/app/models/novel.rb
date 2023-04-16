# frozen_string_literal: true

# Novel
class Novel
  include Mongoid::Document

  field :_id, type: String, overwrite: true
  field :title, type: String
  field :user_account_id, type: String

  index({ user_account_id: 1 })

  def self.novel_collection
    db = Mongoid::Clients.default
    db[:novels]
  end
end
