require 'rest-client'
require 'securerandom'

module UserService

  module_function

  def getMailRegex()
    /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end

  def registerFacebook(facebookId, role, token)
    begin
      if checkFacebookAccessToken(token)
        checkRegsiteredUser = User.where(facebook_id: facebookId)
        if checkRegsiteredUser.length == 0 && checkFacebookAccessToken(token)
          createFacebookUser(facebookId, role)
        else
          user = checkRegsiteredUser[0]
          # まだ確認中ステータスのユーザの場合はレコードを再作成
          if user.status == UserConstants::STATUS_CONFIRMING && user.delete
            createFacebookUser(facebookId, role)
          else
            { status: ResponseConstants::HTTP_STATUS_403 }
          end
        end
      else
        { status: ResponseConstants::HTTP_STATUS_400 }
      end
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end

  def registerEmail(email, role, password)
    begin
      createUserFlg = true
      selectedUser = User.where(email: email)
      # ステータスとメール認証の有効期限が切れているかチェック
      if selectedUser.length > 0
        targetUser = selectedUser[0]
        if targetUser.status == UserConstants::STATUS_CONFIRMING &&
           targetUser.email_auth.expired_at < Time.now.utc
          createUserFlg = targetUser.delete
        else
          createUserFlg = false
        end
      end      
      if createUserFlg
        userId = CommonService::generateUid()
        token = CommonService::generateToken()
        mailSendResult = MailSendUtil::sendAuthMail(email, userId, token)
        if mailSendResult
          createEmailUser(email, role, password, userId, token)
        else
          { status: ResponseConstants::HTTP_STATUS_403 }
        end
      else
        { status: ResponseConstants::HTTP_STATUS_400 }
      end
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end

  def authEmail(userId, token, password, purpose, session)
    begin
      user = User.find(userId)
      if user.nil?
        { status: ResponseConstants::HTTP_STATUS_400 }
      else
        if (purpose == UserConstants::MAIL_AUTH_PURPOSE_REGSITER && user.status == UserConstants::STATUS_CONFIRMING) ||
           (purpose == UserConstants::MAIL_AUTH_PURPOSE_CHANGE && user.status == UserConstants::STATUS_ACTIVE)
          if !user.authenticate(password) || user.email_auth.nil?
            { status: ResponseConstants::HTTP_STATUS_403 }
          elsif user.email_auth.expired_at < Time.now.utc
            if purpose == UserConstants::MAIL_AUTH_PURPOSE_REGSITER
              user.delete
            else
              deleteEmailAuth(user)
            end
            { status: ResponseConstants::HTTP_STATUS_401 }
          else
            if purpose == UserConstants::MAIL_AUTH_PURPOSE_CHANGE
              if user.update(email: user.email_auth.temp_email)
                deleteEmailAuth(user)
                if !user.student_profile.nil?
                  getResponseLoginStudent(user, session)
                elsif !user.company_profile.nil?
                  getResponseLoginCompany(user, session)
                else
                  { status: ResponseConstants::HTTP_STATUS_500 }
                end
              else
                { status: ResponseConstants::HTTP_STATUS_500 }
              end
            else
              { status: ResponseConstants::HTTP_STATUS_200, data: {
                user_id: userId,
                email: user.email_auth.temp_email,
                user_category: user.role,
                auth_category: UserConstants::AUTH_EMAIL
              }}
            end  
          end
        end
      end
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end

  def createFacebookUser(facebookId, role)
    userId = CommonService::generateUid()
    newUser = User.new(
      _id: userId, 
      facebook_id: facebookId,
      status: UserConstants::STATUS_CONFIRMING,
      role: role,
      password: "dummy"
    )
    if newUser.save
      { status: ResponseConstants::HTTP_STATUS_200, data: { user_id: userId } }
    else
      { status: ResponseConstants::HTTP_STATUS_500 }
    end
  end

  def createEmailUser(email, role, password, userId, token)
    newUser = User.new(
      _id: userId, 
      email: email,
      status: UserConstants::STATUS_CONFIRMING,
      role: role,
      password: password,
      email_auth: {
        temp_email: email,
        token: token,
        expired_at: getPlusOneDay()
      }
    )
    if newUser.save
      { status: ResponseConstants::HTTP_STATUS_200 }
    else
      { status: ResponseConstants::HTTP_STATUS_500 }
    end
  end
 
  def facebookLoginResult(facebookId, token, session)
    begin
      selectuser = User.where(facebook_id: facebookId)
      if selectuser.length != 0 && checkFacebookAccessToken(token) && selectuser[0].status == UserConstants::STATUS_ACTIVE
        user = selectuser[0]
        if !user.student_profile.nil?
          getResponseLoginStudent(user, session)
        elsif !user.company_profile.nil?
          getResponseLoginCompany(user, session)
        else
          { status: ResponseConstants::HTTP_STATUS_403 }
        end
      else
        { status: ResponseConstants::HTTP_STATUS_403 }
      end
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end

  def emailLoginResult(email, password, session)
    begin
      selectuser = User.where(email: email)
      if selectuser.length != 0 &&
         selectuser[0].status == UserConstants::STATUS_ACTIVE &&
         selectuser[0].authenticate(password)
        user = selectuser[0]
        if !user.student_profile.nil?
          getResponseLoginStudent(user, session)
        elsif !user.company_profile.nil?
          getResponseLoginCompany(user, session)
        else
          { status: ResponseConstants::HTTP_STATUS_403 }
        end
      else
        { status: ResponseConstants::HTTP_STATUS_403 }
      end
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end

  def checkNotDuplicateEmail(email)
    User.where(email: email).length == 0
  end

  def checkFacebookAccessToken(token)
    begin
      res = JSON.parse(RestClient.get FacebookApiConstants::TOKEN_CHECK_URL + token);
      res["data"]["is_valid"]
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
      false
    end
  end

  def preCheckEdit(password, emailBefore, emailAfter)
    (password.blank? || password.length > 5) &&
    (!emailAfter.blank? && emailAfter.match(UserService::getMailRegex())) &&
    (emailBefore == emailAfter || UserService::checkNotDuplicateEmail(emailAfter))
  end

  def getEmailAuthSend(emailBefore, emailAfter, authCategory, updateUser)
    if UserConstants::AUTH_EMAIL == authCategory && emailBefore != emailAfter
      token = CommonService::generateToken()
      result = MailSendUtil::sendEmailChangeMail(emailAfter, updateUser._id, token)
      if result.nil?
        nil
      else
        {
          temp_email: emailAfter,
          token: token,
          expired_at: getPlusOneDay()
        }
      end
    else
      nil
    end
  end

  def getMessageUserInfo(messageUsersFromDb)
    imageBucket = GoogleCloudStorageUtil::getBucket()
    userInfos = User.find(messageUsersFromDb.map { |u| u[:user_id] })
    messageUsersFromDb.map { |u|
      userInfo = userInfos.filter{ |i| i._id == u[:user_id] }
      if userInfo.length > 0
        u["image_url"] = getImageUrl(userInfo[0], imageBucket)
        if userInfo[0].role == UserConstants::ROLE_STUDENT
          u["name"] = userInfo[0].student_profile.last_name + " " + userInfo[0].student_profile.first_name
          u["gender"] = userInfo[0].student_profile.gender
          u["user_category"] = UserConstants::ROLE_STUDENT
        else
          u["name"] = userInfo[0].company_profile.company_name
          u["gender"] = "company"
          u["user_category"] = UserConstants::ROLE_COMPANY
        end
        u
      end
    }
  end

  def getCommentUsers(comments)
    imageBucket = GoogleCloudStorageUtil::getBucket()
    commentUsers = User.where(
      status: UserConstants::STATUS_ACTIVE,
      role: UserConstants::ROLE_STUDENT,
      _id: { '$in': comments.map { |c| c.user_id} }
    )
    commentUsers.map { |u|
      comment = comments.find { |c|
        c.user_id == u._id
      }
      studentdata = StudentService::getStudentResponse(
        u._id,
        u.student_profile.last_name,
        u.student_profile.first_name,
        u.student_profile.gender,
        getImageUrl(u, imageBucket),
        u.student_profile.department,
        u.student_profile.school_category,
        u.student_profile.year,
        nil,
        u.student_profile.prefecture_code,
        nil,
        nil,
        nil
      )
      studentdata[:data]["comment"] = comment.post_comment
      studentdata[:data]["comment_updated_at"] = comment.updated_at
      studentdata[:data]
    }.sort { |a, b|
      b["comment_updated_at"] <=> a["comment_updated_at"]
    }
  end

  def getMessageCounterUserInfo(counterUserId)
    counterUser = User.find(counterUserId)
    if counterUser.nil?
      nil
    else
      {
        user_id: counterUser._id,
        name: counterUser.role == UserConstants::ROLE_STUDENT ?
          counterUser.student_profile.last_name + " " + counterUser.student_profile.first_name :
          counterUser.company_profile.company_name,
        gender: counterUser.role == UserConstants::ROLE_STUDENT ?
        counterUser.student_profile.gender : "company",
        image_url: getImageUrl(counterUser, nil)
      }
    end
  end

  def updateStudentUser(user, password, email, imageFile, imageUrl, student, emailAuthSend)
    imageFileName = imageFile.nil? ? nil : GoogleCloudStorageUtil::updateImageFile(imageFile, user._id, user.image_file_name)
    userUpdateFlg = password.blank? ?
      imageFileName.nil? ?
        user.update(
          status: UserConstants::STATUS_ACTIVE,
          email: email,
          email_auth: emailAuthSend,
          student_profile: student,
          image_url: imageUrl
        ) :
        user.update(
          status: UserConstants::STATUS_ACTIVE,
          email: email,
          email_auth: emailAuthSend,
          image_url: nil,
          image_file_name: imageFileName,
          student_profile: student
        )
      : 
      imageFileName.nil? ?
        user.update(
          status: UserConstants::STATUS_ACTIVE,
          email: email,
          email_auth: emailAuthSend,
          password: password,
          student_profile: student,
          image_url: imageUrl
        ) :
        user.update(
          status: UserConstants::STATUS_ACTIVE,
          email: email,
          email_auth: emailAuthSend,
          image_url: nil,
          image_file_name: imageFileName,
          password: password,
          student_profile: student
        )
    if userUpdateFlg
      if !user.email_auth.nil? && emailAuthSend.nil?
        deleteEmailAuth(user)
      end
      true
    else
      false
    end
  end

  def updateCompanyUser(user, password, email, imageFile, imageUrl, company, emailAuthSend)
    imageFileName = imageFile.nil? ? nil : GoogleCloudStorageUtil::updateImageFile(imageFile, user._id, user.image_file_name)
    userUpdateFlg = password.blank? ?
      imageFileName.nil? ?
        user.update(
          status: UserConstants::STATUS_ACTIVE,
          email: email,
          email_auth: emailAuthSend,
          company_profile: company
        ) :
        user.update(
          status: UserConstants::STATUS_ACTIVE,
          email: email,
          email_auth: emailAuthSend,
          image_url: nil,
          image_file_name: imageFileName,
          company_profile: company
        )
      : 
      imageFileName.nil? ?
        user.update(
          status: UserConstants::STATUS_ACTIVE,
          email: email,
          email_auth: emailAuthSend,
          password: password,
          company_profile: company
        ) :
        user.update(
          status: UserConstants::STATUS_ACTIVE,
          email: email,
          email_auth: emailAuthSend,
          image_url: nil,
          image_file_name: imageFileName,
          password: password,
          company_profile: company
        )
    if userUpdateFlg
      if !user.email_auth.nil? && emailAuthSend.nil?
        deleteEmailAuth(user)
      end
      true
    else
      false
    end
  end

  def getResponseLoginStudent(user, session)
    StudentService::getStudentResponse(
      user._id,
      user.student_profile.last_name,
      user.student_profile.first_name,
      user.student_profile.gender,
      getImageUrl(user, nil),
      user.student_profile.department,
      user.student_profile.school_category,
      user.student_profile.year,
      session,
      nil,
      nil,
      nil,
      nil,
      MessageService::existUnReadMessage(user._id),
      getAuthCategory(user)
    )
  end

  def getResponseLoginCompany(user, session)
    CompanyService::getCompanyResponse(
      user._id,
      user.company_profile.company_name,
      user.role,
      getImageUrl(user, nil),
      session,
      nil,
      nil,
      nil,
      nil,
      MessageService::existUnReadMessage(user._id),
      getAuthCategory(user)
    )
  end

  def getPlusOneDay()
    Time.now.utc + 24*60*60
  end

  def deleteEmailAuth(user)
    user.unset(:email_auth)
  end

  def getUserCollection()
    db = Mongoid::Clients.default
    db[:user]
  end
 
  def getAuthCategory(user)
    user.facebook_id.nil? ? UserConstants::AUTH_EMAIL : UserConstants::AUTH_FACEBOOK
  end

  def getImageUrl(user, imageBucket)
    if user.image_file_name.nil?
      user.image_url
    else
      GoogleCloudStorageUtil::getImageUrl(user.image_file_name, imageBucket)
    end
  end

  private_class_method
    :createFacebookUser
    :checkFacebookAccessToken
    :getLoginStudent
    :getLoginCompany
    :getPlusOneDay
    :getUserCollection
    :getImageUrl
end
