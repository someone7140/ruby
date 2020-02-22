require 'rest-client'
require 'securerandom'

module StudentService

  module_function

  def registerStudentProfile(studentRegistParam, session)
    begin
      checkRegsiteredUser = User.where(_id: studentRegistParam[:user_id])
      imageUrlForRegister = studentRegistParam[:image_file].nil? ? studentRegistParam[:image_url] : nil
      imageFileNameForRegister = studentRegistParam[:image_file].nil? ? nil : GoogleCloudStorageUtil::updateImageFile(studentRegistParam[:image_file], studentRegistParam[:user_id], nil)
      # userの情報は事前にチェック
      if checkRegsiteredUser.length == 1 &&
         UserService::preCheckRegister(checkRegsiteredUser[0].status, studentRegistParam[:password], studentRegistParam[:email])
        # user情報の更新
        updateUser = checkRegsiteredUser[0]
        if updateUser.update(
          status: UserConstants::STATUS_ACTIVE,
          email: studentRegistParam[:email],
          password: studentRegistParam[:password],
          image_url: imageUrlForRegister,
          image_file_name: imageFileNameForRegister,
          student_profile: {
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
          }
        )
          getStudentResponse(
            studentRegistParam[:user_id],
            studentRegistParam[:last_name],
            studentRegistParam[:first_name],
            studentRegistParam[:gender],
            imageFileNameForRegister.nil? ? imageUrlForRegister : GoogleCloudStorageUtil::getImageUrl(imageFileNameForRegister, nil),
            studentRegistParam[:department],
            studentRegistParam[:school_category],
            studentRegistParam[:year],
            session
          )
        else
          { status: ResponseConstants::HTTP_STATUS_400 }
        end
      else
        { status: ResponseConstants::HTTP_STATUS_400 }
      end
    rescue => _
      { status: ResponseConstants::HTTP_STATUS_500 }
    end
  end

  def editStudentProfile(studentRegistParam, userId, session)
    begin
      regsiteredUser = User.where(_id: userId)
      # userの情報は事前にチェック
      if regsiteredUser.length > 0 && !regsiteredUser[0].student_profile.nil? &&
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
        updateResult = UserService::updateStudentUser(
          updateUser,
          studentRegistParam[:password],
          studentRegistParam[:email],
          studentRegistParam[:image_file],
          student
        )
        if updateResult
          getStudentResponse(
            userId,
            studentRegistParam[:last_name],
            studentRegistParam[:first_name],
            studentRegistParam[:gender],
            updateUser.image_file_name.nil? ?
              updateUser.image_url : GoogleCloudStorageUtil::getImageUrl(updateUser.image_file_name, nil),
            studentRegistParam[:department],
            studentRegistParam[:school_category],
            studentRegistParam[:year],
            session
          )
        else
          { status: ResponseConstants::HTTP_STATUS_400 }
        end
      else
        { status: ResponseConstants::HTTP_STATUS_400 }
      end
    rescue => _
      { status: ResponseConstants::HTTP_STATUS_500 }
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
          image_url: selectuser[0].image_file_name.nil? ? selectuser[0].image_url : GoogleCloudStorageUtil::getImageUrl(selectuser[0].image_file_name, nil),
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
        selectuser[0].image_file_name.nil? ? selectuser[0].image_url : GoogleCloudStorageUtil::getImageUrl(selectuser[0].image_file_name, nil),
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
    rescue => _
      { status: ResponseConstants::HTTP_STATUS_500 }
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
    messageUnRead = false
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
    { status: ResponseConstants::HTTP_STATUS_200,
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
        message_un_read: messageUnRead
      }
    }
  end

end
