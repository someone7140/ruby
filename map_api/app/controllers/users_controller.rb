class UsersController < ApplicationController
  def create
    userIdManage = IdManage.find_by(key: Constants::USER_ID_KEY)
    if userIdManage then
      userId = userIdManage.value + 1
      userIdManage.value = userId
      userIdManage.save()
      time = Time.now
      user = User.new(_id: userId, name: params[:name], email: params[:email], password: params[:password], created_at: time, updated_at: time)
      user.save()
      render json: { status: Constants::HTTP_STATUS_200, data: user }
    else
      render json: { status: Constants::HTTP_STATUS_500, message: 'ユーザの作成に失敗しました。問い合わせ窓口にお問い合わせください。'}
    end
    
  end
end
