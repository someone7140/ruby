# frozen_string_literal: true

module ResponseConstants
  HTTP_STATUS_200 = 200
  HTTP_STATUS_202 = 202
  HTTP_STATUS_400 = 400
  HTTP_STATUS_401 = 401
  HTTP_STATUS_403 = 403
  HTTP_STATUS_500 = 500
end

module UserConstants
  STATUS_ACTIVE = 'active'
  STATUS_SUSPEND = 'suspend'
  STATUS_CONFIRMING = 'confirming'

  ROLE_ADMIN = 'admin'
  ROLE_USER = 'user'
end

module MasterConstants
  # プロフィールの病名
  PROFILE_DISEASE_LIST = [
    { key: 'adhd', value: 'ADHD', group: 'developmental' },
    { key: 'asd', value: 'ASD', group: 'developmental' },
    { key: 'depression', value: 'うつ', group: 'mental' },
    { key: 'cyclophrenia', value: '躁鬱', group: 'mental' },
    { key: 'schizophrenia', value: '統合失調症', group: 'mental' },
    { key: 'hsp', value: 'HSP', group: 'peculiar' },
    { key: 'none', value: '該当無し' }
  ].freeze
  # プロフィールの病名グループ
  PROFILE_DISEASE_GROUP_LIST = [
    { key: 'developmental', value: '発達障害' },
    { key: 'mental', value: '精神障害' },
    { key: 'peculiar', value: '特殊気質' }
  ].freeze
  # チャットのカテゴリー（今のことろプロフィールの病名グループと同じ）
  CHAT_CATEGORY_LIST = PROFILE_DISEASE_GROUP_LIST
  # 投稿カテゴリー
  POST_CATEGORY_LIST = [
    { key: 'adhd', value: 'ADHD', group: 'developmental' },
    { key: 'asd', value: 'ASD', group: 'developmental' },
    { key: 'depression', value: 'うつ', group: 'mental' },
    { key: 'cyclophrenia', value: '躁鬱', group: 'mental' },
    { key: 'schizophrenia', value: '統合失調症', group: 'mental' },
    { key: 'hsp', value: 'HSP', group: 'peculiar' },
    { key: 'other', value: 'その他' }
  ].freeze
  # 問い合わせカテゴリー
  INQUIRY_CATEGORY_LIST = [
    { key: 'post', value: '記事について' },
    { key: 'chat', value: 'チャットについて' },
    { key: 'site', value: 'サイトについて' },
    { key: 'request', value: '要望' },
    { key: 'other', value: 'その他' }
  ].freeze
end
