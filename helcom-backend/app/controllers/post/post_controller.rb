# frozen_string_literal: true

module Post
  # 投稿に関わるコントローラー
  class PostController < ApplicationController
    include PostService
    include ResponseConstants
    include UserConstants

    before_action :logged_in_user, only: %i[
      post_create post_edit
      refer_user_posts refer_admin_posts refer_all_users_posts
      post_user_count
    ]
    before_action :admin_logged_in_user, only: [:admin_post_create]

    # 通常ユーザによる記事投稿
    def post_create
      # 記事投稿
      new_post = PostCrudService.get_create_post(
        post_create_param[:title],
        post_create_param[:url],
        post_create_param[:category],
        post_create_param[:open_flg],
        ROLE_USER,
        session[:user_id]
      )
      if new_post.nil?
        render json: { status: HTTP_STATUS_400 }
      else
        new_post.save!
        render json: { status: HTTP_STATUS_200 }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    # 管理者ユーザによる記事投稿
    def admin_post_create
      # 記事投稿
      new_post = PostCrudService.get_create_post(
        post_create_param[:title],
        post_create_param[:url],
        post_create_param[:category],
        post_create_param[:open_flg],
        ROLE_ADMIN,
        session[:user_id]
      )
      if new_post.nil?
        render json: { status: HTTP_STATUS_400 }
      else
        new_post.save!
        render json: { status: HTTP_STATUS_200 }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def post_create_param
      params.require(:post_create).permit(:title, :url, :category, :open_flg)
    end

    # 記事の編集
    def post_edit
      PostCrudService.edit_post(
        post_edit_param[:post_id],
        post_edit_param[:title],
        post_edit_param[:url],
        post_edit_param[:category],
        post_edit_param[:open_flg],
        session[:user_id]
      )
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def post_edit_param
      params.require(:post_edit).permit(:post_id, :title, :url, :category, :open_flg)
    end

    # 記事の削除
    def post_delete
      PostCrudService.delete_post(
        post_delete_param[:post_id], session[:user_id]
      )
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def post_delete_param
      params.require(:post_delete).permit(:post_id)
    end

    # 自分の投稿記事参照
    def refer_own_post_info
      post = PostCrudService.get_own_post(params[:post_id], session[:user_id])
      if post.nil?
        render json: { status: HTTP_STATUS_401 }
      else
        render json: { status: HTTP_STATUS_200, post_info: post }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    # 記事を踏んだユーザのカウント
    def post_user_count
      PostManagementService.add_post_user_count(
        post_user_count_param[:post_id],
        session[:user_id]
      )
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def post_user_count_param
      params.require(:post_user_count).permit(:post_id)
    end

    # ユーザIDを指定して記事一覧を取得
    def refer_user_posts
      user_posts = PostCrudService.get_user_posts(
        session[:user_id],
        params[:user_id],
        params[:limit].to_i,
        params[:post_category]
      )
      if user_posts.nil?
        render json: { status: HTTP_STATUS_403 }
      else
        render json: { status: HTTP_STATUS_200, user_posts: user_posts }
      end
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    # 管理者記事一覧を取得
    def refer_admin_posts
      admin_posts = PostCrudService.get_admin_user_posts(params[:limit].to_i, params[:post_category])
      render json: { status: HTTP_STATUS_200, user_posts: admin_posts }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    # ユーザ記事一覧を取得
    def refer_all_users_posts
      all_users_posts = PostCrudService.get_all_users_posts(params[:limit].to_i, params[:post_category])
      render json: { status: HTTP_STATUS_200, user_posts: all_users_posts }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end
  end
end
