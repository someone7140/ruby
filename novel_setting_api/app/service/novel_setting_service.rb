# frozen_string_literal: true

require 'jwt'
require 'securerandom'

# 小説設定に関するサービス
class NovelSettingService
  # 小説の設定レコード作成
  def self.create_setting(user_account_id, novel_id, name, order)
    id = CommonService.generate_uid
    NovelSettingRepository.create_setting(id, user_account_id, novel_id, name, order)
  end
end
