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

end
