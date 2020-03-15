class StudentProfileController < ApplicationController
  def editStudentProfile
    render json: StudentService::editStudentProfile(studentRegistParam, session)
  end

  def getStudent
    userId = session[:user_id]
    if userId.blank?
      render json: { status: ResponseConstants::HTTP_STATUS_403 }
    else
      render json: StudentService::getStudentProfile(userId)
    end
  end
 
  def deleteStudent
    userId = session[:user_id]
    if userId.blank?
      render json: { status: ResponseConstants::HTTP_STATUS_403 }
    else
      render json: StudentService::deleteStudent(userId)
    end
  end

  def getStudentForRef
    if params[:user_id].blank?
      # ブランクの場合は自ユーザの情報
      render json: StudentService::getStudentByUser(session[:user_id])
    else
      render json: StudentService::getStudentByUser(params[:user_id])
    end
  end

  def studentRegistParam
    params.require(:student).permit(
      :user_id,
      :password,
      :image_url,
      :image_file,
      :email,
      :last_name,
      :first_name,
      :gender,
      :school_category,
      :year,
      :department,
      :prefecture_code,
      :introduction,
      certification:[],
      interest:[]
    )
  end

end
