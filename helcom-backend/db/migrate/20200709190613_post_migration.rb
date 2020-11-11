# frozen_string_literal: true

# 記事投稿のマイグレーション
class PostMigration < Mongoid::Migration
  include PostInfo
  def self.up
    Post.create_indexes
  end

  def self.down; end
end
