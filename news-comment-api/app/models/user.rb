class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword
  field :_id, type: String
  field :status, type: String
  field :role, type: String
  field :facebook_id, type: String
  field :email, type: String
  field :image_url, type: String
  field :image_file_name, type: String
  field :password_digest, type: String
  embeds_one :student_profile
  embeds_one :company_profile
  embeds_one :email_auth
  index({ email: 1 ,facebook_id: 1 }, unique: true)
  has_secure_password
  validates :status, inclusion: { in:
    [
      UserConstants::STATUS_ACTIVE,
      UserConstants::STATUS_SUSPEND,
      UserConstants::STATUS_CONFIRMING
    ]
  }
  validates :role, inclusion: { in:
    [
      UserConstants::ROLE_ADMIN,
      UserConstants::ROLE_COMPANY,
      UserConstants::ROLE_STUDENT
    ]
  }
end
