require 'rest-client'
require 'uri'

module NewsService

  module_function

  def getNews(category ,word)
    begin
      newsFromDb = getNewsFromDb(category, word)
      newsFromBing = getNewsFromBing(category, word).map { |b|
        findResult = newsFromDb.each_with_index.select { |d, i| d[:url] == b[:url] }
        if findResult.length > 0
          b["comments_count"] = findResult[0][0]["comments_count"]
          newsFromDb.delete_at(findResult[0][1])
        else
          b["comments_count"] = 0
        end
        b
      }
      result = newsFromBing.concat(newsFromDb).sort { |a, b|
        (b["comments_count"] <=> a["comments_count"]).nonzero? || b[:date_published] <=> a[:date_published]
      }.map.with_index { |news, index|
        news["index"] = index
        news
      }
      { status: ResponseConstants::HTTP_STATUS_200,
        data: result
      }
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end

  def getNewsFromBing(category, word)
    url = nil
    # デフォルトのカテゴリー
    defaultCategory = MasterConstants::NEWS_CATEGORY.map { |c| c[:key] }
    if !word.blank?
      query = URI.encode_www_form(q: word)
      url = NewsApiConstants::BING_NEWS_SEARCH_ENDPOINT + "&" + query
    else
      url = NewsApiConstants::BING_NEWS_ENDPOINT
    end
    if !category.blank?
      url = url + "&category=" + category
    end
    res = RestClient.get url, {
      'Ocp-Apim-Subscription-Key': NewsApiConstants::BING_NEWS_KEY,
      'Accept-Language': 'ja-JP'
    }
    resJson = JSON.parse(res)
    resJson["value"].map { |value|
      providerName = value["provider"].present? && value["provider"].length > 0 ? value["provider"][0]["name"] : "";
      imageUrl = value["image"].present? ? value["image"]["thumbnail"]["contentUrl"] : "";
      { title: value["name"],
        url: value["url"],
        image_url: imageUrl,
        description: value["description"],
        provider: providerName,
        date_published: Time.parse(value["datePublished"]),
        category: value["category"]
      }
    }.filter { |value|
      # wordとcategoryがある場合は対象カテゴリーで絞り込み
      if !word.blank? && !category.blank?
        category == value[:category]
      else
        defaultCategory.include?(value[:category])
      end
    }
  end

  def getNewsFromDb(category, word)
    # 7日前の日付を取得
    before7days = Time.now.utc - 7.days
    # 取得する列定義
    project = { "$project" => {
        url: 1,
        category: 1,
        title: 1,
        date_published: 1,
        image_url: 1,
        description: 1,
        provider: 1,
        comments_count: {"$size": "$comments"}
      }}
    # デフォルトのカテゴリー
    defaultCategory = MasterConstants::NEWS_CATEGORY.map { |c| c[:key] }
    collection = getCommentNewsCollection()
    if !word.blank? && !category.blank?
      collection.find.aggregate([
        { "$match" => { category: category } },
        { "$match" => { "date_published" => { "$gte" => before7days } } },
        { "$match" => { "$or" => [
          { "title" => Regexp.new(".*" + word + ".*") },
          { "description" => Regexp.new(".*" + word + ".*") }
          ]}
        },
        project
      ]).to_a
    elsif !category.blank?
      collection.aggregate([
        { "$match" => { category: category } },
        { "$match" => { "date_published" => { "$gte" => before7days } } },
        project
      ]).to_a
    elsif !word.blank?
      collection.aggregate([
        { "$match" => { "category" => { "$in" => defaultCategory } } },
        { "$match" => { "date_published" => { "$gte" => before7days } } },
        { "$match" => { "$or" => [
            { "title" => Regexp.new(".*" + word + ".*") },
            { "description" => Regexp.new(".*" + word + ".*") }
          ]}
        },
        project
      ]).to_a
    else
      collection.aggregate([
        { "$match" => { "category" => { "$in" => defaultCategory } } },
        { "$match" => { "date_published" => { "$gte" => before7days } } },
        project
      ]).to_a
    end
  end

  def getCommentNewsCollection()
    db = Mongoid::Clients.default
    db[:comment_news]
  end
 
  private_class_method :getNewsFromBing, :getNewsFromDb, :getCommentNewsCollection
end
