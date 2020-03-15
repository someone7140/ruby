module MessageService

  module_function

  def getMessageUsers(userId)
    begin
      resultMessageUsers = getRecentMessage(userId, nil)
      result = []
      if resultMessageUsers.length > 0
        result = UserService::getMessageUserInfo(resultMessageUsers)
      end
      { status: ResponseConstants::HTTP_STATUS_200, data: result }
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end

  def getMessages(userId, counterUserId)
    begin
      messageResult = Message.where(user_ids: [userId, counterUserId].sort)
      counterUserInfo = UserService::getMessageCounterUserInfo(counterUserId)
      if messageResult.length < 1 || messageResult[0].message_records.length < 1
        { status: ResponseConstants::HTTP_STATUS_200 , data: {
          un_read_flg: false,
          counter_user_info: counterUserInfo,
          message_records: []
        }}
      else
        message = messageResult[0]
        messageRecords = message.message_records.sort_by { |m| m.send_at }.reverse
        # 最新メッセージの送り主が自分でなければ未読フラグを更新
        if messageRecords[0].send_user_id != userId
          message.un_read_flg = false
          message.save
        end
        { status: ResponseConstants::HTTP_STATUS_200, data: {
          un_read_flg: message.un_read_flg,
          counter_user_info: counterUserInfo,
          message_records: messageRecords
        }}
      end
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end
 
  def postMessage(userId, counterUserId, message)
    begin
      now = Time.now.utc
      recentMessage = getRecentMessage(userId, counterUserId)
      messageId = CommonService::generateUid()
      if recentMessage.length > 0
        collection = getMessageCollection()
        collection.update_one(
          { "user_ids" => [userId, counterUserId].sort },
          { "$push" => { 
            "message_records" => {
              "message_id" => messageId,
              "send_user_id" => userId,
              "received_user_id" => counterUserId,
              "message" => message,
              "send_at" => now
            }
          }}
        )
        collection.update_one(
          { "user_ids" => [userId, counterUserId].sort },
          { "$set" => {
            "un_read_flg": true
          }}
        )
      else
        Message.create!(
          user_ids: [userId, counterUserId].sort,
          un_read_flg: true,
          message_records: [
            message_id: messageId,
            send_user_id: userId,
            received_user_id: counterUserId,
            message: message,
            send_at: now
          ]
        )
      end
      { status: ResponseConstants::HTTP_STATUS_200 }
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end
 
  def getRecentMessage(userId, counterUserId)
    collection = getMessageCollection()
    matchCondition = counterUserId.nil? ?
      { "$match" => { "$expr" => { "$in" => [userId, "$user_ids"] } } } :
      { "$match" => { user_ids: [userId, counterUserId].sort } }
    collection.aggregate([
      matchCondition,
      { "$unwind" => "$message_records" },
      { "$sort" => { "message_records.send_at" => -1 } },
      { "$group" => {
        _id: "$_id",
        "user_ids" => { "$first" => "$user_ids" },
        "un_read_flg" => { "$first" => "$un_read_flg" },
        "recent_message" => { "$first" => "$message_records" }
      }},
      { "$sort" => { "recent_message.send_at" => -1 } }
    ]).to_a.map { |m|
      counterUserId = m[:user_ids].filter { |i|
        i != userId
      }[0]
      if !m[:recent_message].nil?
        message = m[:recent_message]
        {
          user_id: counterUserId,
          un_read_flg: message[:send_user_id] == userId ? false : m[:un_read_flg],
          recent_message: message[:message][0, 50],
          recent_message_date: message[:send_at]
        }
      else
        {
          user_id: counterUserId,
          un_read_flg: false
        }
      end
    }
  end

  def updateUnReadFlg(userId, counterUserId, flg)
    begin
      collection = getMessageCollection()
      collection.update_one(
        { "user_ids" => [userId, counterUserId].sort },
        { "$set" => {
          "un_read_flg": flg
        }}
      )
      { status: ResponseConstants::HTTP_STATUS_200 }
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end

  def existUnReadMessage(userId)
    begin
      getRecentMessage(userId, nil).filter{ |m|
        m[:un_read_flg]
      }.length > 0
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
      false
    end
  end

  def deleteAllMessage(userId)
    Message.where(user_ids: { "$in" => [userId, "$user_ids"] }).delete
  end
  
  def getMessageCollection()
    db = Mongoid::Clients.default
    db[:messages]
  end

  private_class_method :getMessageCollection
end
