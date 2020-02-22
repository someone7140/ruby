class CommentController < ApplicationController
  def registComment
    userId = session[:user_id]
    if userId.blank?
      render json: { status: ResponseConstants::HTTP_STATUS_403 }
    else
      render json: CommentService::regist(
        commentAddParam[:url],
        commentAddParam[:category],
        commentAddParam[:date_published].blank? ? nil : DateTime.parse(commentAddParam[:date_published]),
        commentAddParam[:title],
        commentAddParam[:image_url], 
        commentAddParam[:description],
        commentAddParam[:provider],
        userId,
        commentAddParam[:post_comment])
    end
  end

  def commentAddParam
    params.require(:comment_add).permit(
      :url,
      :category,
      :date_published,
      :title,
      :image_url,
      :description,
      :provider,
      :post_comment)
  end

  def deleteComment
    userId = session[:user_id]
    if userId.blank?
      render json: { status: ResponseConstants::HTTP_STATUS_403 }
    else
      render json: CommentService::delete(
        commentDeleteParam[:url],
        userId
      )
    end
  end

  def commentDeleteParam
    params.require(:comment_delete).permit(:url)
  end

  def getOwnCommentByUrl
    user_id = session[:user_id]
    if user_id.blank?
      render json: { status: ResponseConstants::HTTP_STATUS_403 }
    else
      render json: CommentService::getOwnCommentByUrl(
        commentByUrlParam[:url],
        user_id
      )
    end
  end

  def getCommentOtherUsers
    render json: CommentService::getCommentByUrlExceptUser(
      commentByUrlParam[:url],
      session[:user_id]
    )
  end

  def commentByUrlParam
    params.require(:comment_byurl).permit(:url)
  end

  def getCommentFilterUser
    if params[:user_id].blank?
      # ブランクの場合は自ユーザのコメント一覧を取得
      render json: CommentService::getCommentUserWithNews(session[:user_id])
    else
      render json: CommentService::getCommentUserWithNews(params[:user_id])
    end
  end 
end
