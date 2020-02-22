class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :_id, type: String
  field :user_ids, :type => Array
  field :un_read_flg, type: Boolean
  embeds_many :message_records
  validates :user_ids, presence: true
  index({ user_ids: 1 })
end
