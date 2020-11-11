# frozen_string_literal: true

# グループチャットのマイグレーション
class GroupChatLogMigration < Mongoid::Migration
  include ChatInfo
  def self.up
    GroupChatLog.create_indexes
  end

  def self.down; end
end
