class CompanyProfile
  include Mongoid::Document
  field :company_name, type: String
  field :category, type: String
  field :prefecture_code, type: Integer
  field :url, type: String
  field :detail, type: String
  embedded_in :user
  validates :company_name, presence: true
  validates :category, presence: true
  validates :prefecture_code, inclusion: { in: UserConstants::PREFECTURE_CODE_LIST }
end
