# frozen_string_literal: true

# NovelContents
class NovelContents
  include Mongoid::Document

  field :_id, type: String, overwrite: true
  field :novel_id, type: String
  field :user_account_id, type: String
  field :content_records, type: Array
  field :content_headlines, type: Array

  index({ novel_id: 1 })
  index({ user_account_id: 1 })

  def self.novel_contents_collection
    db = Mongoid::Clients.default
    db[:novel_contents]
  end
end
