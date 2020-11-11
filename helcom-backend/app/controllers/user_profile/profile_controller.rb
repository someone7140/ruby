# frozen_string_literal: true

module UserProfile
  # プロフィールに関わるコントローラー
  class ProfileController < ApplicationController
    include ResponseConstants
    include UserConstants
    include UserService

    before_action :logged_in_user

    # プロフィール参照
    def profile_refer
      # ユーザプロフィール情報の取得
      user_profile_info = UserProfileService.get_profile_info(session[:user_id], params[:user_id])
      if user_profile_info.nil?
        render json: { status: HTTP_STATUS_400 }
      else
        profile = user_profile_info[:profile]
        if profile.nil?
          render json: { status: HTTP_STATUS_200, user_profile: {
            user_id: user_profile_info[:user_id],
            email: user_profile_info[:email],
            twitter_id: user_profile_info[:twitter_id]
          } }
        else
          render json: { status: HTTP_STATUS_200, user_profile: {
            user_id: user_profile_info[:user_id],
            email: user_profile_info[:email],
            twitter_id: user_profile_info[:twitter_id],
            name: profile.name,
            image_url: profile.image_url,
            sickness: profile.sickness,
            talking_sickness: profile.talking_sickness,
            introduction: profile.introduction,
            purpose: profile.purpose,
            twitter_url: profile.twitter_url,
            instagram_url: profile.instagram_url,
            facebook_url: profile.facebook_url
          } }
        end
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    # プロフィール登録・編集
    def profile_regist
      user_info = UserProfileService.regist_profile_info(session[:user_id], profile_regist_param)
      if user_info.nil?
        render json: { status: HTTP_STATUS_400 }
      else
        render json: { status: HTTP_STATUS_200, user: user_info }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def profile_regist_param
      params.require(:profile_regist).permit(
        :name,
        :sickness,
        :talking_sickness,
        :introduction,
        :purpose,
        :twitter_url,
        :instagram_url,
        :facebook_url,
        :image_file
      )
    end

    # SNSのリンクを踏んだユーザのカウント
    def sns_user_count
      UserProfileService.update_sns_user_count(
        session[:user_id],
        sns_user_count_param[:user_id],
        sns_user_count_param[:sns_type]
      )
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def sns_user_count_param
      params.require(:sns_user_count).permit(
        :user_id,
        :sns_type
      )
    end
  end
end
