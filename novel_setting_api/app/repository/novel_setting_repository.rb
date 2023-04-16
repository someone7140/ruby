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

  # 設定名称変更
  def self.update_setting_name(id, user_account_id, name)
    collection = NovelSetting.novel_setting_collection
    collection.update_one(
      { '_id' => id, 'user_account_id' => user_account_id },
      { '$set' => {
        'name' => name
      } }
    )
  end

  # 小説の設定リスト取得
  def self.setting_list(user_account_id, novel_id)
    NovelSetting.where(user_account_id:, novel_id:).order_by(order: :asc).only(:_id, :name, :settings)
  end

  # 指定したidで小説の設定情報を取得
  def self.setting_by_id(id, user_account_id, novel_id)
    NovelSetting.find_by(_id: id, user_account_id:, novel_id:).only(:_id, :name, :settings)
  end
end
