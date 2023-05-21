# frozen_string_literal: true

require 'jwt'
require 'securerandom'

# 小説に関するサービス
class NovelService
  # 小説のレコード作成
  def self.create_novel(user_account_id, title)
    novel_id = CommonService.generate_uid
    novel = NovelRepository.create_novel(novel_id, user_account_id, title)
    # 小説内容のレコードを作成
    NovelContentsRepository.create_novel_contents(CommonService.generate_uid, novel_id, user_account_id, [], [])
    novel
  end

  # 小説のタイトル更新
  def self.update_novel_title(id, user_account_id, title)
    NovelRepository.update_novel_title(id, user_account_id, title)
  end

  # 小説のリスト取得
  def self.user_novel_list(user_account_id)
    NovelRepository.user_novel_list(user_account_id).map do |novel|
      {
        id: novel._id,
        title: novel.title
      }
    end
  end
end
