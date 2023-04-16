# frozen_string_literal: true

# NovelSettingコレクションのリポジトリ
class NovelSettingRepository
  # 設定作成
  def self.create_setting(id, user_account_id, novel_id, name, order)
    novel_setting = NovelSetting.new(
      _id: id,
      novel_id:,
      user_account_id:,
      name:,
      order:,
      settings: []
    )
    novel_setting.save!
    novel_setting
  end
end
