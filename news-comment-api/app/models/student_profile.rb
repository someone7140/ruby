class StudentProfile
  include Mongoid::Document
  field :last_name, type: String
  field :first_name, type: String
  field :gender, type: String
  field :school_category, type: String
  field :year, type: Integer
  field :department, type: String
  field :prefecture_code, type: Integer
  field :introduction, type: String
  field :certification, :type => Array, :default => []
  field :interest, :type => Array, :default => []
  embedded_in :user
  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :gender, inclusion: { in: [UserConstants::GENDER_MAN, UserConstants::GENDER_WOMAN] }
  validates :school_category, inclusion: { in:
    [
      UserConstants::SCHOOL_CATEGORY_GAKUBU,
      UserConstants::SCHOOL_CATEGORY_IN,
      UserConstants::SCHOOL_CATEGORY_SENMON,
      UserConstants::SCHOOL_CATEGORY_TANDAI
    ]
  }
  validates :year, presence: true
  validates :department, presence: true
  validates :prefecture_code, inclusion: { in: UserConstants::PREFECTURE_CODE_LIST }
end
