# frozen_string_literal: true

# 通報のマイグレーション
class PostWhistleMigration < Mongoid::Migration
  include PostInfo
  def self.up
    PostWhistle.create_indexes
  end

  def self.down; end
end
