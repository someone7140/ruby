class Initial < Mongoid::Migration
  def self.up
    User.create_indexes
    CommentNews.create_indexes
    Message.create_indexes
  end

  def self.down
  end
end
