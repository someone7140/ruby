require 'rest-client'
require 'securerandom'

module UserService

  module_function

  def getMailRegex()
    /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end

  def registerFacebook(facebookId, role, token)
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

  def facebookLoginResult(facebookId, token, session)
    begin
      selectuser = User.where(facebook_id: facebookId)
      if selectuser.length != 0 && checkFacebookAccessToken(token) && selectuser[0].status == UserConstants::STATUS_ACTIVE
        user = selectuser[0]
        if !user.student_profile.nil?
          StudentService::getStudentResponse(
            user._id,
            user.student_profile.last_name,
            user.student_profile.first_name,
            user.student_profile.gender,
            user.image_file_name.nil? ? user.image_url : GoogleCloudStorageUtil::getImageUrl(user.image_file_name, nil),
            user.student_profile.department,
            user.student_profile.school_category,
            user.student_profile.year,
            session,
            nil,
            nil,
            nil,
            nil,
            MessageService::existUnReadMessage(user._id)
          )
        elsif !user.company_profile.nil?
          CompanyService::getCompanyResponse(
            user._id,
            user.company_profile.company_name,
            user.role,
            user.image_file_name.nil? ? user.image_url : GoogleCloudStorageUtil::getImageUrl(user.image_file_name, nil),
            session,
            nil,
            nil,
            nil,
            nil,
            MessageService::existUnReadMessage(user._id)
          )
        else
          { status: ResponseConstants::HTTP_STATUS_403 }
        end
      else
        { status: ResponseConstants::HTTP_STATUS_403 }
      end
    rescue => _
      { status: ResponseConstants::HTTP_STATUS_500 }
    end
  end

  def checkNotDuplicateEmail(email)
    User.where(email: email).length == 0
  end

  def checkFacebookAccessToken(token)
    begin
      res = JSON.parse(RestClient.get FacebookApiConstants::TOKEN_CHECK_URL + token);
      res["data"]["is_valid"]
    rescue => _
      false
    end
  end

  def preCheckRegister(status, password, email)
    status == UserConstants::STATUS_CONFIRMING &&
    !password.blank? && password.length > 5 &&
    !email.blank? && email.match(UserService::getMailRegex()) && checkNotDuplicateEmail(email)
  end

  def preCheckEdit(password, emailBefore, emailAfter)
    (password.blank? || password.length > 5) &&
    (!emailAfter.blank? && emailAfter.match(UserService::getMailRegex())) &&
    (emailBefore == emailAfter || UserService::checkNotDuplicateEmail(emailAfter))
  end

  def getMessageUserInfo(messageUsersFromDb)
    imageBucket = GoogleCloudStorageUtil::getBucket()
    userInfos = User.find(messageUsersFromDb.map { |u| u[:user_id] })
    messageUsersFromDb.map { |u|
      userInfo = userInfos.filter{ |i| i._id == u[:user_id] }
      if userInfo.length > 0
        u["image_url"] = userInfo[0].image_file_name.nil? ? userInfo[0].image_url : GoogleCloudStorageUtil::getImageUrl(userInfo[0].image_file_name, imageBucket)
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
        u.image_file_name.nil? ? u.image_url : GoogleCloudStorageUtil::getImageUrl(u.image_file_name, imageBucket),
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
        image_url: counterUser.image_file_name.nil? ?
          counterUser.image_url :
          GoogleCloudStorageUtil::getImageUrl(counterUser.image_file_name, nil)
      }
    end
  end

  def updateStudentUser(user, password, email, imageFile, student)
    imageFileName = imageFile.nil? ? nil : GoogleCloudStorageUtil::updateImageFile(imageFile, user._id, user.image_file_name)
    password.blank? ?
      imageFileName.nil? ?
        user.update(
          email: email,
          student_profile: student
        ) :
        user.update(
          email: email,
          image_url: nil,
          image_file_name: imageFileName,
          student_profile: student
        )
      : 
      imageFileName.nil? ?
        user.update(
          email: email,
          password: password,
          student_profile: student
        ) :
        user.update(
          email: email,
          image_url: nil,
          image_file_name: imageFileName,
          password: password,
          student_profile: student
        )
  end

  def updateCompanyUser(user, password, email, imageFile, company)
    imageFileName = imageFile.nil? ? nil : GoogleCloudStorageUtil::updateImageFile(imageFile, user._id, user.image_file_name)
    password.blank? ?
      imageFileName.nil? ?
        user.update(
          email: email,
          company_profile: company
        ) :
        user.update(
          email: email,
          image_url: nil,
          image_file_name: imageFileName,
          company_profile: company
        )
      : 
      imageFileName.nil? ?
        user.update(
          email: email,
          password: password,
          company_profile: company
        ) :
        user.update(
          email: email,
          image_url: nil,
          image_file_name: imageFileName,
          password: password,
          company_profile: company
        )
  end

  private_class_method
    :createFacebookUser
    :checkFacebookAccessToken
end
