# frozen_string_literal: true

require 'jwt'
require 'securerandom'

# 小説に関するサービス
class NovelService
  # 小説のレコード作成
  def self.create_novel(user_account_id, title)
    id = CommonService.generate_uid
    NovelRepository.create_novel(id, user_account_id, title)
  end

  # 小説のタイトル更新
  def self.update_novel_title(id, user_account_id, title)
    NovelRepository.update_novel_title(id, user_account_id, title)
  end

  # 小説のリスト取得
  def self.user_novel_list(user_account_id)
    NovelRepository.user_novel_list(user_account_id)
  end
end
