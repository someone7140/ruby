# frozen_string_literal: true

require 'bson'

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

  # 設定内容更新
  def self.update_settings(id, user_account_id, settings)
    # childrenの変数をhash化する
    get_hash_children = lambda { |children|
      if !children.nil? && children.length.positive?
        children.map do |setting|
          setting_hash = {}
          setting_hash['_id'] = setting[:_id]
          setting_hash['value'] = setting[:value]
          setting_hash['children'] = get_hash_children.call(setting[:children])
          setting_hash
        end
      else
        []
      end
    }

    collection = NovelSetting.novel_setting_collection
    setting_hash_list = settings.map do |setting|
      setting_hash = {}
      setting_hash['_id'] = setting[:_id]
      setting_hash['value'] = setting[:value]
      setting_hash['children'] = get_hash_children.call(setting[:children])
      setting_hash
    end

    collection.update_one(
      { '_id' => id, 'user_account_id' => user_account_id },
      { '$set' => {
        'settings' => setting_hash_list
      } }
    )
  end

  # 小説の設定リスト取得
  def self.setting_list(user_account_id, novel_id)
    NovelSetting.only(:_id, :name, :settings).where(user_account_id:, novel_id:).order_by(order: :asc)
  end

  # 指定したidで小説の設定情報を取得
  def self.setting_by_id(id, user_account_id, novel_id)
    NovelSetting.only(:_id, :name, :settings).find_by(_id: id, user_account_id:, novel_id:)
  end
end
