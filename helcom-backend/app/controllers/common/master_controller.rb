# frozen_string_literal: true

module Common
  # マスターに関わるコントローラー
  class MasterController < ApplicationController
    include ResponseConstants
    include MasterConstants

    before_action :logged_in_user

    # マスターデータ取得
    def get_master
      render json: { status: HTTP_STATUS_200, master: {
        profile_disease_list: PROFILE_DISEASE_LIST,
        profile_disease_group_list: PROFILE_DISEASE_GROUP_LIST,
        chat_category_list: CHAT_CATEGORY_LIST,
        post_category_list: POST_CATEGORY_LIST,
        inquiry_category_list: INQUIRY_CATEGORY_LIST
      } }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end
  end
end
