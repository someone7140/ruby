require 'rest-client'
require 'securerandom'

module CompanyService

  module_function

  def editCompanyProfile(companyRegistParam, session)
    begin
      userId = companyRegistParam[:user_id]
      regsiteredUser = User.where(_id: userId)
      # userの情報は事前にチェック
      if regsiteredUser.length > 0 &&
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
        authCategory = UserService::getAuthCategory(updateUser)
        emailAuthSend = UserService::getEmailAuthSend(
          regsiteredUser[0].email,
          companyRegistParam[:email],
          authCategory,
          updateUser
        )
        updateResult = UserService::updateCompanyUser(
          updateUser,
          companyRegistParam[:password],
          emailAuthSend.nil? ? companyRegistParam[:email] : regsiteredUser[0].email,
          companyRegistParam[:image_file],
          companyRegistParam[:image_file].nil? ? companyRegistParam[:image_url] : nil,
          company,
          emailAuthSend
        )
        if updateResult
          getCompanyResponse(
            userId,
            companyRegistParam[:company_name],
            updateUser.role,
            UserService::getImageUrl(updateUser, nil),
            session,
            nil,
            nil,
            nil,
            nil,
            false,
            authCategory,
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

  def getCompanyProfile(userId)
    selectuser = User.where(_id: userId)
    if selectuser.length != 0 && selectuser[0].status == UserConstants::STATUS_ACTIVE &&
       selectuser[0].role != UserConstants::ROLE_STUDENT && !selectuser[0].company_profile.nil?
      company = selectuser[0].company_profile
      { status: ResponseConstants::HTTP_STATUS_200,
        data: {
          user_id: userId,
          email: selectuser[0].email,
          image_url: UserService::getImageUrl(selectuser[0], nil),
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
        UserService::getImageUrl(selectuser[0], nil),
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
    messageUnRead = false,
    authCategory = nil,
    isEmailAuthSendFlg = false
  )
    # セッションが入っている場合、ユーザIDを入れる
    if !session.nil?
      session[:user_id] = userId
    end
    { status: isEmailAuthSendFlg ? ResponseConstants::HTTP_STATUS_202 : ResponseConstants::HTTP_STATUS_200,
      data: {
        user_id: userId,
        company_name: companyName,
        user_category: userCategory,
        image_url: imageUrl,
        category: companyCategory,
        prefecture_code: prefectureCode,
        url: url,
        detail: detail,
        message_un_read: messageUnRead,
        auth_category: authCategory
      }
    }
  end

end
