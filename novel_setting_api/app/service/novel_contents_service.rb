# frozen_string_literal: true

require 'jwt'
require 'securerandom'

# 小説内容に関するサービス
class NovelContentsService
  # 小説内容の更新
  def self.update_contents(id, user_account_id, content_records, content_headlines)
    NovelContentsRepository.update_novel_contents(id, user_account_id, content_records, content_headlines)
  end

  # 小説IDを指定して内容の取得
  def self.get_contens_by_novel_id(novel_id, user_account_id)
    novel = NovelRepository.user_novel_by_id(novel_id, user_account_id)
    novel_contents = NovelContentsRepository.get_contents_by_novel_id(novel_id, user_account_id)
    raise InvalidParameterError, 'can not get novel contents' if novel.nil? || novel_contents.nil?

    {
      id: novel_contents._id,
      title: novel.title,
      contentRecords: novel_contents.content_records,
      contentHeadlines: novel_contents.content_headlines
    }
  end
end
