# frozen_string_literal: true

# Novelコレクションのリポジトリ
class NovelRepository
  # 小説作成
  def self.create_novel(id, user_account_id, title)
    novel = Novel.new(
      _id: id,
      user_account_id:,
      title:
    )
    novel.save!
    novel
  end

  # 小説のタイトル更新
  def self.update_novel_title(id, user_account_id, title)
    collection = Novel.novel_collection
    collection.update_one(
      { '_id' => id, 'user_account_id' => user_account_id },
      { '$set' => {
        'title' => title
      } }
    )
  end

  # 小説のリスト取得
  def self.user_novel_list(user_account_id)
    Novel.only(:_id, :title).where(user_account_id:)
  end

  # 指定したidで小説の情報を取得
  def self.user_novel_by_id(id, user_account_id)
    Novel.only(:_id, :title).find_by(_id: id, user_account_id:)
  end

  # 小説設定の削除
  def self.delete_novel(id, user_account_id)
    Novel.where(_id: id, user_account_id:).delete
  end
end
