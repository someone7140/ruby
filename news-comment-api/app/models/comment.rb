class Comment
  include Mongoid::Document
  field :user_id, type: String
  field :post_comment, type: String
  field :updated_at, type: DateTime
  embedded_in :comment_news
  validates :user_id, presence: true
  validates :post_comment, presence: true
  validates :updated_at, presence: true
end
