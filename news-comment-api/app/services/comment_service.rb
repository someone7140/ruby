module CommentService

  module_function

  def regist(url, category, date_published, title, imageUrl, description, provider, userId, postComment)
    begin
      now = Time.now.utc
      commentNewsGet = CommentNews.only(:url).where(url: url)
      if commentNewsGet.length == 0
        CommentNews.create!(
          url: url,
          category: category,
          date_published: date_published,
          title: title,
          image_url: imageUrl,
          description: description,
          provider: provider,
          comments: [
            user_id: userId,
            post_comment: postComment,
            updated_at: now
          ]
        )
      else
        commentNewsCollection = getCommentNewsCollection()
        commentNewsAndCommentGet = getCommentByUrlAndUser(url, userId)
        if commentNewsAndCommentGet.length == 0
          commentNewsCollection.update_one(
            { "url" => url },
            { "$push" => { 
              "comments" => {
                "user_id" => userId,
                "post_comment" => postComment,
                "updated_at" => now
              }
            }}
          )
        else
          commentNewsCollection.update_one(
            { "url" => url, "comments.user_id" => userId },
            { "$set" => {
                "comments.$.post_comment": postComment,
                "comments.$.updated_at": now
              }
            }
          )
        end
      end
      { status: ResponseConstants::HTTP_STATUS_200 }
    rescue => _
      { status: ResponseConstants::HTTP_STATUS_400 }
    end
  end

  def delete(url, userId)
    begin
      commentNewsCollection = getCommentNewsCollection()
      commentNewsCollection.update_one(
        { "url" => url },
        { "$pull" => { "comments" => { "user_id" => userId } } }
      )
      { status: ResponseConstants::HTTP_STATUS_200 }
    rescue => _
      { status: ResponseConstants::HTTP_STATUS_500 }
    end
  end

  def deleteAllUser(userId)
    CommentNews.where({ "comments.user_id" => userId }).update_all(
      { "$pull" => { "comments" => { "user_id" => userId } } }
    )
  end

  def getOwnCommentByUrl(url, userId)
    begin
      result = getCommentByUrlAndUser(url, userId)
      if result.length > 0 && result[0][:comments].length > 0
        { status: ResponseConstants::HTTP_STATUS_200, data: result[0][:comments][0] } 
      else
        { status: ResponseConstants::HTTP_STATUS_200, data: nil }
      end
    rescue => _
      { status: ResponseConstants::HTTP_STATUS_500 }
    end
  end

  def getCommentUserWithNews(userId)
    begin
      collection = getCommentNewsCollection()
      result = collection.aggregate([
        { "$match" => { "comments.user_id" => userId } },
        { "$unwind" => "$comments" },
        { "$match" => { "comments.user_id" => userId } },
        { "$group" => {
          _id: "$_id",
          "category" => { "$first" => "$category" },
          "comments" => { "$push" => "$comments" },
          "date_published" => { "$first" => "$date_published" },
          "description" => { "$first" => "$description" },
          "image_url" => { "$first" => "$image_url" },
          "provider" => { "$first" => "$provider" },
          "title" => { "$first" => "$title" },
          "url" => { "$first" => "$url" }
        }},
        { "$sort" => { "comments.updated_at" => -1 } }
      ]).to_a
      if result.length > 0
        { status: ResponseConstants::HTTP_STATUS_200, data: result }
      else
        { status: ResponseConstants::HTTP_STATUS_200, data: nil }
      end
    rescue => _
      { status: ResponseConstants::HTTP_STATUS_500 }
    end
  end

  def getCommentByUrlExceptUser(url, userId)
    begin
      commentNews = CommentNews.where(url: url)
      if commentNews.length > 0 && commentNews[0].comments.length > 0
        comments = commentNews[0].comments.to_a.select { |c| c.user_id != userId }
        { status: ResponseConstants::HTTP_STATUS_200, data: UserService::getCommentUsers(comments) }
      else
        { status: ResponseConstants::HTTP_STATUS_200, data: [] }
      end
    rescue => _
      { status: ResponseConstants::HTTP_STATUS_500 }
    end
  end
 
  def getCommentByUrlAndUser(url, userId)
    collection = getCommentNewsCollection()
    collection.aggregate([
      { "$match" => { url: url } },
      { "$unwind" => "$comments" },
      { "$match" => { "comments.user_id" => userId } },
      { "$group" => { _id: "$_id", "comments" => { "$push" => "$comments" } } }
    ]).to_a
  end

  def getCommentNewsCollection()
    db = Mongoid::Clients.default
    db[:comment_news]
  end

  private_class_method :getCommentByUrlAndUser, :getCommentNewsCollection
end
