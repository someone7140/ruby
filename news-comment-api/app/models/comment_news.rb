class CommentNews
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: String
  field :url, type: String
  field :category, type: String
  field :date_published, type: DateTime
  field :title, type: String
  field :image_url, type: String
  field :description, type: String
  field :provider, type: String
  embeds_many :comments
  index({ url: 1 }, unique: true)
  index({ category: 1 })
  index({ date_published: -1 })
  index "comments.user_id" => 1
  index "comments.updated_at" => -1
  validates :url, presence: true
  validates :date_published, presence: true
end
