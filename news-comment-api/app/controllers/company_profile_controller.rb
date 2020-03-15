class CompanyProfileController < ApplicationController
  def editCompanyProfile
    render json: CompanyService::editCompanyProfile(companyRegistParam, session)
  end

  def getCompany
    userId = session[:user_id]
    if userId.blank?
      render json: { status: ResponseConstants::HTTP_STATUS_403 }
    else
      render json: CompanyService::getCompanyProfile(userId)
    end
  end

  def getCompanyForRef
    if params[:user_id].blank?
      # ブランクの場合は自ユーザの情報
      render json: CompanyService::getCompanyByUser(session[:user_id])
    else
      render json: CompanyService::getCompanyByUser(params[:user_id])
    end
  end

  def companyRegistParam
    params.require(:company).permit(
      :user_id,
      :password,
      :image_url,
      :image_file,
      :email,
      :company_name,
      :category,
      :prefecture_code,
      :url,
      :detail
    )
  end

end
