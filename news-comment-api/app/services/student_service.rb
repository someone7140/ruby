require 'rest-client'
require 'securerandom'

module StudentService

  module_function

  def editStudentProfile(studentRegistParam, session)
    begin
      userId = studentRegistParam[:user_id]
      regsiteredUser = User.where(_id: userId)
      # userの情報は事前にチェック
      if regsiteredUser.length > 0 &&
         UserService::preCheckEdit(studentRegistParam[:password], regsiteredUser[0].email, studentRegistParam[:email])
        updateUser = regsiteredUser[0]
        student = StudentProfile.new(
          last_name: studentRegistParam[:last_name],
          first_name: studentRegistParam[:first_name],
          gender: studentRegistParam[:gender],
          school_category: studentRegistParam[:school_category],
          year: studentRegistParam[:year],
          department: studentRegistParam[:department],
          prefecture_code: studentRegistParam[:prefecture_code],
          introduction: studentRegistParam[:introduction],
          certification: studentRegistParam[:certification],
          interest: studentRegistParam[:interest]
        )
        # user情報の更新
        authCategory = UserService::getAuthCategory(updateUser)
        emailAuthSend = UserService::getEmailAuthSend(
          regsiteredUser[0].email,
          studentRegistParam[:email],
          authCategory,
          updateUser
        )
        updateResult = UserService::updateStudentUser(
          updateUser,
          studentRegistParam[:password],
          emailAuthSend.nil? ? studentRegistParam[:email] : regsiteredUser[0].email,
          studentRegistParam[:image_file],
          studentRegistParam[:image_file].nil? ? studentRegistParam[:image_url] : nil,
          student,
          emailAuthSend
        )
        if updateResult
          getStudentResponse(
            userId,
            studentRegistParam[:last_name],
            studentRegistParam[:first_name],
            studentRegistParam[:gender],
            UserService::getImageUrl(updateUser, nil),
            studentRegistParam[:department],
            studentRegistParam[:school_category],
            studentRegistParam[:year],
            session,
            nil,
            nil,
            nil,
            nil,
            false,
            UserService::getAuthCategory(updateUser),
            !emailAuthSend.nil?
          )
        else
          { status: ResponseConstants::HTTP_STATUS_400 }
        end
      else
        { status: ResponseConstants::HTTP_STATUS_400 }
      end
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end
 
  def getStudentProfile(userId)
    selectuser = User.where(_id: userId)
    if selectuser.length != 0 && selectuser[0].status == UserConstants::STATUS_ACTIVE &&
       selectuser[0].role == UserConstants::ROLE_STUDENT && !selectuser[0].student_profile.nil?
      student = selectuser[0].student_profile
      { status: ResponseConstants::HTTP_STATUS_200,
        data: {
          user_id: userId,
          email: selectuser[0].email,
          image_url: UserService::getImageUrl(selectuser[0], nil),
          last_name: student.last_name,
          first_name: student.first_name,
          gender: student.gender,
          school_category: student.school_category,
          year: student.year,
          department: student.department,
          prefecture_code: student.prefecture_code,
          introduction: student.introduction,
          certification: student.certification,
          interest: student.interest
        }
      }
    else
      { status: ResponseConstants::HTTP_STATUS_403 }
    end
  end

  def getStudentByUser(userId)
    selectuser = User.where(_id: userId)
    if selectuser.length != 0 && selectuser[0].status == UserConstants::STATUS_ACTIVE &&
       selectuser[0].role == UserConstants::ROLE_STUDENT && !selectuser[0].student_profile.nil?
      student = selectuser[0].student_profile
      getStudentResponse(
        userId,
        student.last_name,
        student.first_name,
        student.gender,
        UserService::getImageUrl(selectuser[0], nil),
        student.department,
        student.school_category,
        student.year,
        nil,
        student.prefecture_code,
        student.introduction,
        student.certification,
        student.interest
      )
    else
      { status: ResponseConstants::HTTP_STATUS_200, data: nil }
    end
  end

  def deleteStudent(userId)
    begin
      userGet = User.where(_id: userId)
      if userGet.length > 0
        user = userGet[0]
        MessageService::deleteAllMessage(userId)
        CommentService::deleteAllUser(userId)
        GoogleCloudStorageUtil::deleteImageFile(user.image_file_name, nil)
        user.delete
      end
      { status: ResponseConstants::HTTP_STATUS_200 }
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
    end
  end

  def getStudentResponse(
    userId,
    lastName,
    firstName,
    gender,
    imageUrl,
    department,
    schoolCategory,
    year,
    session = nil,
    prefectureCode = nil,
    introduction = nil,
    certification = nil,
    interest = nil,
    messageUnRead = false,
    authCategory = nil,
    isEmailAuthSendFlg = false
  )
    # セッションが入っている場合、ユーザIDを入れる
    if !session.nil?
      session[:user_id] = userId
    end
    yearValue = year.to_s + "年生"
    schoolCategoryMap = MasterConstants::SCHOOL_CATEGORY.find { |c|
      c[:key] == schoolCategory
    }
    if !schoolCategoryMap.nil? 
      yearValue = schoolCategoryMap[:value] + yearValue
    end
    { status: isEmailAuthSendFlg ? ResponseConstants::HTTP_STATUS_202 : ResponseConstants::HTTP_STATUS_200,
      data: {
        user_id: userId,
        name: lastName + " " + firstName,
        user_category: UserConstants::ROLE_STUDENT,
        gender: gender,
        image_url: imageUrl,
        department: department,
        year: yearValue,
        prefecture_code: prefectureCode,
        introduction: introduction,
        certification: certification,
        interest: interest,
        message_un_read: messageUnRead,
        auth_category: authCategory
      }
    }
  end

end
