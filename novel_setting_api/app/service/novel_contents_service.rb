# frozen_string_literal: true

require 'jwt'
require 'securerandom'

# 小説内容に関するサービス
class NovelContentsService
  # 小説内容の更新
  def self.update_contents(id, user_account_id, content_records, content_headlines)
    content_record_hash_list = content_records.map do |record|
      record_hash = {}
      record_hash['type'] = record[:type]
      record_hash['key'] = record[:key]
      record_hash['children'] = [{ text: record[:children][0][:text] }]
      record_hash
    end
    content_headline_hash_list = content_headlines.map do |headline|
      headline_hash = {}
      headline_hash['key'] = headline[:key]
      headline_hash['name'] = headline[:name]
      headline_hash
    end

    NovelContentsRepository.update_novel_contents(id, user_account_id, content_record_hash_list,
                                                  content_headline_hash_list)
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
