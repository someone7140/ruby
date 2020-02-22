class MessageRecord
  include Mongoid::Document
  field :message_id, type: String
  field :send_user_id, type: String
  field :received_user_id, type: String
  field :message, type: String
  field :send_at, type: DateTime
  validates :message_id, presence: true
  validates :send_user_id, presence: true
  validates :received_user_id, presence: true
  validates :message, presence: true
  validates :send_at, presence: true
end
