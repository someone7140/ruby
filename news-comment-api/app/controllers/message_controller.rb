class MessageController < ApplicationController
  def getMessageUsers
    userId = session[:user_id]
    if userId.blank?
      render json: { status: ResponseConstants::HTTP_STATUS_403 }
    else
      render json: MessageService::getMessageUsers(userId)
    end
  end

  def getMessages
    userId = session[:user_id]
    if userId.blank? || params[:counter_user_id].blank?
      render json: { status: ResponseConstants::HTTP_STATUS_403 }
    else
      render json: MessageService::getMessages(userId, params[:counter_user_id])
    end
  end

  def postMessage
    userId = session[:user_id]
    if userId.blank?
      render json: { status: ResponseConstants::HTTP_STATUS_403 }
    elsif postMessageParam[:counter_user_id].blank? || postMessageParam[:message].blank?
      render json: { status: ResponseConstants::HTTP_STATUS_400 }
    else
      render json: MessageService::postMessage(userId, postMessageParam[:counter_user_id], postMessageParam[:message])
    end
  end

  def postMessageParam
    params.require(:message).permit(
      :counter_user_id,
      :message
    )
  end

  def updateUnRead
    userId = session[:user_id]
    if userId.blank?
      render json: { status: ResponseConstants::HTTP_STATUS_403 }
    elsif updateUnReadParam[:counter_user_id].nil? || updateUnReadParam[:flg].nil?
      render json: { status: ResponseConstants::HTTP_STATUS_400 }
    else
      render json: MessageService::updateUnReadFlg(userId, updateUnReadParam[:counter_user_id], updateUnReadParam[:flg])
    end
  end

  def updateUnReadParam
    params.require(:un_read).permit(
      :counter_user_id,
      :flg
    )
  end
end
