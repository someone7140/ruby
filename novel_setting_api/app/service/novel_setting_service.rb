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

  # 小説の設定名称作成
  def self.update_setting_name(id, user_account_id, name)
    NovelSettingRepository.update_setting_name(id, user_account_id, name)
  end

  # 小説の設定リスト取得
  def self.setting_list(user_account_id, novel_id)
    # 小説の情報を取得
    novel = NovelRepository.user_novel_by_id(novel_id, user_account_id)
    raise InvalidParameterError, 'can not get novel info' if novel.nil?

    # 設定のリスト取得
    setting_list = NovelSettingRepository.setting_list(user_account_id, novel_id).map do |setting|
      {
        id: setting._id,
        name: setting.name,
        settings: setting.settings
      }
    end

    # 結果返却
    {
      novelTitle: novel.title,
      settingList: setting_list
    }
  end

  # ID指定で設定を取得
  def self.setting_by_id(id, user_account_id, novel_id)
    # 小説の情報を取得
    novel = NovelRepository.user_novel_by_id(novel_id, user_account_id)
    raise InvalidParameterError, 'can not get novel info' if novel.nil?

    # 設定の取得
    setting = NovelSettingRepository.setting_by_id(id, user_account_id, novel_id)
    raise InvalidParameterError, 'can not get novel setting' if setting.nil?

    # 結果返却
    {
      novelTitle: novel.title,
      setting: {
        id: setting._id,
        name: setting.name,
        settings: setting.settings
      }
    }
  end
end
