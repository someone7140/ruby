# frozen_string_literal: true

module Post
  # 投稿の通報に関わるコントローラー
  class PostWhistleController < ApplicationController
    include PostService
    include ResponseConstants
    include UserConstants

    before_action :logged_in_user, only: %i[post_whistle_send]
    before_action :admin_logged_in_user, only: [:admin_post_whistle_list]

    # 投稿通報
    def post_whistle_send
      # 投稿の通報
      success_flg = PostManagementService.send_post_whistle(
        post_whistle_send_param[:post_id],
        post_whistle_send_param[:contents],
        session[:user_id]
      )
      if success_flg
        render json: { status: HTTP_STATUS_200 }
      else
        render json: { status: HTTP_STATUS_400 }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def post_whistle_send_param
      params.require(:post_whistle_send).permit(:post_id, :contents)
    end

    # 通報リスト（管理者のみ）
    def admin_post_whistle_list
      render json: {
        status: HTTP_STATUS_200,
        post_whistle_list: PostManagementService.get_whistle_list(params[:limit].to_i)
      }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end
  end
end
