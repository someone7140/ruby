module ResponseConstants
  HTTP_STATUS_200 = 200
  HTTP_STATUS_202 = 202
  HTTP_STATUS_400 = 400
  HTTP_STATUS_401 = 401
  HTTP_STATUS_403 = 403
  HTTP_STATUS_500 = 500
end

module NewsApiConstants
  BING_NEWS_ENDPOINT = "https://api.cognitive.microsoft.com/bing/v7.0/news?freshness=Week&count=40&mkt=ja-JP"
  BING_NEWS_SEARCH_ENDPOINT = "https://api.cognitive.microsoft.com/bing/v7.0/news/search?freshness=Week&count=40&mkt=ja-JP"
  BING_NEWS_KEY = Rails.application.config.rankness.bingNewsKey
  CATEGORY = [
    { key: "Business", value: "ビジネス", enable: true },
    { key: "Entertainment", value: "芸能", enable: false },
    { key: "Japan", value: "国内", enable: true },
    { key: "LifeStyle", value: "ライフスタイル", enable: true },
    { key: "Politics", value: "政治", enable: false },
    { key: "ScienceAndTechnology", value: "サイエンス&テクノロジー", enable: true },
    { key: "Sports", value: "スポーツ", enable: false },
    { key: "World", value: "国際", enable: true }
  ]
end

module FacebookApiConstants
  APP_ID = Rails.application.config.rankness.facebookAppId
  VERSION = "v6.0"
  SECRET = Rails.application.config.rankness.facebookSecret
  TOKEN_CHECK_URL = "https://graph.facebook.com/" + VERSION + "/debug_token?access_token=" + APP_ID + "|" + SECRET + "&input_token="
end

module UserConstants
  STATUS_ACTIVE = "active"
  STATUS_SUSPEND = "suspend"
  STATUS_CONFIRMING = "confirming"

  ROLE_ADMIN = "admin"
  ROLE_STUDENT = "student"
  ROLE_COMPANY = "company"
  
  GENDER_MAN = "man"
  GENDER_WOMAN = "woman"

  SCHOOL_CATEGORY_GAKUBU = "gakubu"
  SCHOOL_CATEGORY_IN = "in"
  SCHOOL_CATEGORY_TANDAI = "tandai"
  SCHOOL_CATEGORY_SENMON = "senmon"

  PREFECTURE_CODE_LIST = [*(1..47)]

  AUTH_FACEBOOK = "facebook"
  AUTH_EMAIL = "email"

  MAIL_AUTH_PURPOSE_REGSITER = "register"
  MAIL_AUTH_PURPOSE_CHANGE = "change"
  MAIL_AUTH_PURPOSE_PASSWORD_RESET = "reset"

end

module GoogleCloudStorageConstants
  PROJECT_ID = Rails.application.config.rankness.gcsProjectId
  CREDENTIAL_PATH = Rails.application.config.rankness.gcsCredentialPath
  BUCKET = Rails.application.config.rankness.gcsBucket
  ICON_PATH = "icon/"
end

module MailConstants
  SEND_GRID_FROM = Rails.application.config.rankness.sendGridFrom
  MAIL_LINK_DOMAIN = Rails.application.config.rankness.mailLinkDomain
end

module MasterConstants
  GENDER = [
    { key: UserConstants::GENDER_MAN, value: "男性" },
    { key: UserConstants::GENDER_WOMAN, value: "女性" }
  ]
  SCHOOL_CATEGORY = [
    { key: UserConstants::SCHOOL_CATEGORY_GAKUBU, value: "学部" },
    { key: UserConstants::SCHOOL_CATEGORY_IN, value: "院" },
    { key: UserConstants::SCHOOL_CATEGORY_TANDAI, value: "短大" },
    { key: UserConstants::SCHOOL_CATEGORY_SENMON, value: "専門" },
  ]
  PREFECTURE = [
    { key: 1, value: "北海道" }, { key: 2, value: "青森県" }, { key: 3, value: "岩手県" }, { key: 4, value: "宮城県" },
    { key: 5, value: "秋田県" }, { key: 6, value: "山形県" }, { key: 7, value: "福島県" }, { key: 8, value: "茨城県" },
    { key: 9, value: "栃木県" }, { key: 10, value: "群馬県" }, { key: 11, value: "埼玉県" }, { key: 12, value: "千葉県" },
    { key: 13, value: "東京都" }, { key: 14, value: "神奈川県" }, { key: 15, value: "新潟県" }, { key: 16, value: "富山県" },
    { key: 17, value: "石川県" }, { key: 18, value: "福井県" }, { key: 19, value: "山梨県" }, { key: 20, value: "長野県" },
    { key: 21, value: "岐阜県" }, { key: 22, value: "静岡県" }, { key: 23, value: "愛知県" }, { key: 24, value: "三重県" },
    { key: 25, value: "滋賀県" }, { key: 26, value: "京都府" }, { key: 27, value: "大阪府" }, { key: 28, value: "兵庫県" },
    { key: 29, value: "奈良県" }, { key: 30, value: "和歌山県" }, { key: 31, value: "鳥取県" }, { key: 32, value: "島根県" },
    { key: 33, value: "岡山県" }, { key: 34, value: "広島県" }, { key: 35, value: "山口県" }, { key: 36, value: "徳島県" },
    { key: 37, value: "香川県" }, { key: 38, value: "愛媛県" }, { key: 39, value: "高知県" }, { key: 40, value: "福岡県" },
    { key: 41, value: "佐賀県" }, { key: 42, value: "長崎県" }, { key: 43, value: "熊本県" }, { key: 44, value: "大分県" },
    { key: 45, value: "宮崎県" }, { key: 46, value: "鹿児島県" }, { key: 47, value: "沖縄県" }
  ]
  FACEBOOK_API = { app_id: FacebookApiConstants::APP_ID, version: FacebookApiConstants::VERSION }
  NEWS_CATEGORY = NewsApiConstants::CATEGORY.select { |c|
    c[:enable]
  }.map { |c|
    { key: c[:key], value: c[:value] }
  }
end
