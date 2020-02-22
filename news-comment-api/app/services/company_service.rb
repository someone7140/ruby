require 'rest-client'
require 'securerandom'

module CompanyService

  module_function

  def registerCompanyProfile(companyRegistParam, session)
    begin
      checkRegsiteredUser = User.where(_id: companyRegistParam[:user_id])
      imageUrlForRegister = companyRegistParam[:image_file].nil? ? companyRegistParam[:image_url] : nil
      imageFileNameForRegister = companyRegistParam[:image_file].nil? ? nil : GoogleCloudStorageUtil::updateImageFile(companyRegistParam[:image_file], companyRegistParam[:user_id], nil)
      # userの情報は事前にチェック
      if checkRegsiteredUser.length == 1 &&
         UserService::preCheckRegister(checkRegsiteredUser[0].status, companyRegistParam[:password], companyRegistParam[:email])
        # user情報の更新
        updateUser = checkRegsiteredUser[0]
        if updateUser.update(
          status: UserConstants::STATUS_ACTIVE,
          email: companyRegistParam[:email],
          password: companyRegistParam[:password],
          image_url: imageUrlForRegister,
          image_file_name: imageFileNameForRegister,
          company_profile: {
            company_name: companyRegistParam[:company_name],
            category: companyRegistParam[:category],
            prefecture_code: companyRegistParam[:prefecture_code],
            url: companyRegistParam[:url],
            detail: companyRegistParam[:detail]
          }
        )
          getCompanyResponse(
            companyRegistParam[:user_id],
            companyRegistParam[:company_name],
            updateUser.role,
            imageFileNameForRegister.nil? ? imageUrlForRegister : GoogleCloudStorageUtil::getImageUrl(imageFileNameForRegister, nil),
            session,
            nil,
            nil,
            nil,
            nil
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

  def editCompanyProfile(companyRegistParam, userId, session)
    begin
      regsiteredUser = User.where(_id: userId)
      # userの情報は事前にチェック
      if regsiteredUser.length > 0 && !regsiteredUser[0].company_profile.nil? &&
         UserService::preCheckEdit(companyRegistParam[:password], regsiteredUser[0].email, companyRegistParam[:email])
        updateUser = regsiteredUser[0]
        company = CompanyProfile.new(
          company_name: companyRegistParam[:company_name],
          category: companyRegistParam[:category],
          prefecture_code: companyRegistParam[:prefecture_code],
          url: companyRegistParam[:url],
          detail: companyRegistParam[:detail]
        )
        # user情報の更新
        updateResult = UserService::updateCompanyUser(
          updateUser,
          companyRegistParam[:password],
          companyRegistParam[:email],
          companyRegistParam[:image_file],
          company
        )
        if updateResult
          getCompanyResponse(
            userId,
            companyRegistParam[:company_name],
            updateUser.role,
            updateUser.image_file_name.nil? ?
              updateUser.image_url : GoogleCloudStorageUtil::getImageUrl(updateUser.image_file_name, nil),
            session,
            nil,
            nil,
            nil,
            nil
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

  def getCompanyProfile(userId)
    selectuser = User.where(_id: userId)
    if selectuser.length != 0 && selectuser[0].status == UserConstants::STATUS_ACTIVE &&
       selectuser[0].role != UserConstants::ROLE_STUDENT && !selectuser[0].company_profile.nil?
      company = selectuser[0].company_profile
      { status: ResponseConstants::HTTP_STATUS_200,
        data: {
          user_id: userId,
          email: selectuser[0].email,
          image_url: selectuser[0].image_file_name.nil? ? selectuser[0].image_url : GoogleCloudStorageUtil::getImageUrl(selectuser[0].image_file_name, nil),
          company_name: company.company_name,
          category: company.category,
          prefecture_code: company.prefecture_code,
          url: company.url,
          detail: company.detail
        }
      }
    else
      { status: ResponseConstants::HTTP_STATUS_403 }
    end
  end

  def getCompanyByUser(userId)
    selectuser = User.where(_id: userId)
    if selectuser.length != 0 && selectuser[0].status == UserConstants::STATUS_ACTIVE &&
       selectuser[0].role != UserConstants::ROLE_STUDENT && !selectuser[0].company_profile.nil?
      company = selectuser[0].company_profile
      getCompanyResponse(
        userId,
        company.company_name,
        selectuser[0].role,
        selectuser[0].image_file_name.nil? ?
          selectuser[0].image_url :
          GoogleCloudStorageUtil::getImageUrl(selectuser[0].image_file_name, nil),
        nil,
        company.category,
        company.prefecture_code,
        company.url,
        company.detail
      )
    else
      { status: ResponseConstants::HTTP_STATUS_200, data: nil }
    end
  end

  def getCompanyResponse(
    userId,
    companyName,
    userCategory,
    imageUrl,
    session = nil,
    companyCategory = nil,
    prefectureCode = nil,
    url = nil,
    detail = nil,
    messageUnRead = false
  )
    # セッションが入っている場合、ユーザIDを入れる
    if !session.nil?
      session[:user_id] = userId
    end
    { status: ResponseConstants::HTTP_STATUS_200,
      data: {
        user_id: userId,
        company_name: companyName,
        user_category: userCategory,
        image_url: imageUrl,
        category: companyCategory,
        prefecture_code: prefectureCode,
        url: url,
        detail: detail,
        message_un_read: messageUnRead
      }
    }
  end

end
