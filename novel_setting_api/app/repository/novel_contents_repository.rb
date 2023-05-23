# frozen_string_literal: true

# NovelContentsコレクションのリポジトリ
class NovelContentsRepository
  # 小説内容の作成
  def self.create_novel_contents(id, novel_id, user_account_id, content_records, content_headlines)
    novel_contents = NovelContents.new(
      _id: id,
      novel_id:,
      user_account_id:,
      content_records:,
      content_headlines:
    )
    novel_contents.save!
    novel_contents
  end

  # 小説内容の更新
  def self.update_novel_contents(id, user_account_id, content_records, content_headlines)
    collection = NovelContents.novel_collection
    collection.update_one(
      { '_id' => id, 'user_account_id' => user_account_id },
      { '$set' => {
        'content_records' => content_records,
        'content_headlines' => content_headlines
      } }
    )
  end

  # 小説IDによる内容の取得
  def self.get_contents_by_novel_id(novel_id, user_account_id)
    NovelContents.find_by(novel_id:, user_account_id:)
  end
end
