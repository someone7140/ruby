class IdManage
  include Mongoid::Document
  field :key, type: String
  field :value, type: Integer
  index({ key: 1 }, unique: true)
end
