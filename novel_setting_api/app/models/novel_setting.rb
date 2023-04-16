# frozen_string_literal: true

# NovelSetting
class NovelSetting
  include Mongoid::Document

  field :_id, type: String, overwrite: true
  field :novel_id, type: String
  field :user_account_id, type: String
  field :name, type: String
  field :order, type: Integer
  field :settings, type: Array

  index({ novel_id: 1 })
  index({ user_account_id: 1 })
end
