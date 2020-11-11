# frozen_string_literal: true

module UserService
  # プロフィール用のサービス
  class UserProfileService
    include CommonService
    include MasterConstants
    include UserConstants
    include UserInfo

    # プロフィールの取得
    def self.get_profile_info(own_user_id, refer_user_id)
      user_find_result = User.where(_id: refer_user_id).only(
        :_id,
        :email,
        :twitter_id,
        :status,
        :role,
        'profile.name',
        'profile.image_url',
        'profile.sickness',
        'profile.talking_sickness',
        'profile.introduction',
        'profile.purpose',
        'profile.twitter_url',
        'profile.instagram_url',
        'profile.facebook_url'
      )
      if user_find_result.empty?
        nil
      else
        user = user_find_result[0]
        if user.status != STATUS_ACTIVE
          nil
        else
          {
            user_id: user._id,
            email: own_user_id == refer_user_id && user.respond_to?('email') ? user.email : nil,
            twitter_id: own_user_id == refer_user_id && user.respond_to?('twitter_id') ? user.twitter_id : nil,
            profile: user.respond_to?('profile') ? user.profile : nil,
            role: user.role
          }
        end
      end
    end

    # プロフィールの登録
    def self.regist_profile_info(own_user_id, regist_params)
      # 既存のプロフィール情報
      user_profile_info = get_profile_info(own_user_id, own_user_id)
      # アップロード前のイメージファイルURL
      if !user_profile_info.nil? && !user_profile_info[:profile].nil?
        before_image_file_url = user_profile_info[:profile].image_url
      end
      # イメージファイルがある場合はアップロードの上URL取得
      image_url = if !regist_params[:image_file].nil?
                    StorageService.update_icon_image_file(
                      own_user_id, regist_params[:image_file], before_image_file_url
                    )
                  else
                    before_image_file_url
                  end
      # 新しいプロフィールのオブジェクト
      new_profile = Profile.new(
        name: regist_params[:name],
        image_url: image_url,
        sickness: regist_params[:sickness],
        talking_sickness: regist_params[:talking_sickness],
        introduction: regist_params[:introduction],
        purpose: regist_params[:purpose],
        twitter_url: regist_params[:twitter_url],
        instagram_url: regist_params[:instagram_url],
        facebook_url: regist_params[:facebook_url]
      )
      if user_profile_info.nil? || !new_profile.valid?
        nil
      else
        user_connection = User.get_user_collection
        update_profile = {
          'profile' => {
            'name' => new_profile.name,
            'image_url' => new_profile.image_url,
            'sickness' => new_profile.sickness,
            'talking_sickness' => new_profile.talking_sickness,
            'introduction' => new_profile.introduction,
            'purpose' => new_profile.purpose,
            'twitter_url' => new_profile.twitter_url,
            'instagram_url' => new_profile.instagram_url,
            'facebook_url' => new_profile.facebook_url
          }
        }
        user_connection.update_one(
          { '_id' => own_user_id },
          { '$set' => update_profile }
        )
        {
          user_id: own_user_id,
          name: new_profile.name,
          image_url: new_profile.image_url,
          role: user_profile_info[:role]
        }
      end
    end

    # SNSを踏んだユーザのカウント
    def self.update_sns_user_count(own_user_id, update_user_id, sns_type)
      # 自ユーザの場合は更新しない
      if own_user_id != update_user_id
        user_collection = User.get_user_collection
        sns_access_proerty = nil
        sns_access_user_id_column = nil

        if sns_type == 'twitter'
          sns_access_proerty = 'twitter_access_users'
          sns_access_user_id_column = 'twitter_access_users.user_id'
        elsif sns_type == 'instagram'
          sns_access_proerty = 'instagram_access_users'
          sns_access_user_id_column = 'instagram_access_users.user_id'
        elsif sns_type == 'facebook'
          sns_access_proerty = 'facebook_access_users'
          sns_access_user_id_column = 'facebook_access_users.user_id'
        end
        # 更新
        if !sns_access_proerty.nil? && !sns_access_user_id_column.nil?
          find_user_access = user_collection.aggregate(
            [
              { '$match' => { '_id' => update_user_id } },
              { '$match' => { sns_access_user_id_column => { '$ne' => own_user_id } } }, # 既にそのユーザが踏んだ履歴がないか
              { '$group' => {
                _id: '$_id'
              } }
            ]
          ).to_a
          unless find_user_access.empty?
            add_access = {
              sns_access_proerty => {
                'user_id' => own_user_id,
                'access_at' => Time.now.utc
              }
            }
            user_collection.update_one(
              { '_id' => update_user_id },
              { '$push' => add_access }
            )
          end
        end
      end
    end

    # SNSを踏んだユーザの削除（退会時）
    def self.delete_sns_user_count(user_id)
      User.where({ 'twitter_access_users.user_id' => user_id }).update_all(
        { '$pull' => { 'twitter_access_users' => { 'user_id' => user_id } } }
      )
      User.where({ 'instagram_access_users.user_id' => user_id }).update_all(
        { '$pull' => { 'instagram_access_users' => { 'user_id' => user_id } } }
      )
      User.where({ 'facebook_access_users.user_id' => user_id }).update_all(
        { '$pull' => { 'facebook_access_users' => { 'user_id' => user_id } } }
      )
    end

    # 自ユーザの基本情報の取得
    def self.get_own_basic_info(user_id)
      user_find_result = User.where(_id: user_id).only(
        :_id,
        :email,
        :twitter_id,
        :status,
        :role,
        'profile.name',
        'profile.image_url'
      )
      if user_find_result.empty?
        nil
      else
        user_find_result[0]
      end
    end
  end
end
