class AuthController < ApplicationController
  def facebookLogin
    facebookId = facebookLoginParam[:facebook_id]
    token = facebookLoginParam[:access_token]
    if !facebookId.blank? && !token.blank?
      render json: UserService::facebookLoginResult(facebookId, token, session)
    else
      render json: { status: ResponseConstants::HTTP_STATUS_400 }
    end
  end

  def facebookLoginParam
    params.require(:facebook_login).permit(:facebook_id, :access_token)
  end

  def emailLogin
    email = emailLoginParam[:email]
    password = emailLoginParam[:password]
    if !email.blank? && !password.blank?
      render json: UserService::emailLoginResult(email, password, session)
    else
      render json: { status: ResponseConstants::HTTP_STATUS_400 }
    end
  end

  def emailLoginParam
    params.require(:email_login).permit(:email, :password)
  end
 
  def logout
    session[:user_id] = nil
    render json: { status: ResponseConstants::HTTP_STATUS_200 }
  end

  def registFacebookUser
    facebookId = facebookRegistParam[:facebook_id]
    role = facebookRegistParam[:role]
    if !facebookId.blank? &&
      (role == UserConstants::ROLE_STUDENT || role == UserConstants::ROLE_COMPANY)
      render json: UserService::registerFacebook(facebookId, role, facebookRegistParam[:access_token])
    else
      render json: { status: ResponseConstants::HTTP_STATUS_400 }
    end
  end

  def facebookRegistParam
    params.require(:facebook_user).permit(:facebook_id, :role, :access_token)
  end

  def registEmailUser
    email = emailRegistParam[:email]
    password = emailRegistParam[:password]
    role = emailRegistParam[:role]
    if !email.blank? && !password.blank? && 
      (role == UserConstants::ROLE_STUDENT || role == UserConstants::ROLE_COMPANY)
      render json: UserService::registerEmail(email, role, password)
    else
      render json: { status: ResponseConstants::HTTP_STATUS_400 }
    end
  end

  def emailRegistParam
    params.require(:email_register).permit(:email, :role, :password)
  end

  def authEmailUser
    userId = emailAuthParam[:user_id]
    password = emailAuthParam[:password]
    token = emailAuthParam[:token]
    authPurpose = emailAuthParam[:auth_purpose]
    if !userId.blank? && !password.blank? && !token.blank? &&
       (authPurpose == UserConstants::MAIL_AUTH_PURPOSE_REGSITER ||
        authPurpose == UserConstants::MAIL_AUTH_PURPOSE_CHANGE ||
        authPurpose == UserConstants::MAIL_AUTH_PURPOSE_PASSWORD_RESET)
      render json: UserService::authEmail(userId, token, password, authPurpose, session)
    else
      render json: { status: ResponseConstants::HTTP_STATUS_400 }
    end
  end

  def emailAuthParam
    params.require(:email_auth).permit(:user_id, :token, :password, :auth_purpose)
  end

end
