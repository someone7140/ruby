# frozen_string_literal: true

# 小説に関わるコントローラー
class NovelController < ApplicationController
  before_action :login_check

  # 小説作成
  def create_novel
    param! :title, String, required: true, blank: false

    auth_payload = session[:auth_payload]
    NovelService.create_novel(auth_payload['id'], params[:title])
    render status: :ok, json: {}
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end

  # 小説タイトル変更
  def update_novel
    param! :id, String, required: true, blank: false
    param! :title, String, required: true, blank: false

    auth_payload = session[:auth_payload]
    NovelService.update_novel_title(params[:id], auth_payload['id'], params[:title])
    render status: :ok, json: {}
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end

  # 登録した小説のリスト
  def novel_list
    auth_payload = session[:auth_payload]
    novels = NovelService.user_novel_list(auth_payload['id'])
    render status: :ok, json: novels
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end

  # 小説削除
  def delete_novel
    param! :id, String, required: true, blank: false

    auth_payload = session[:auth_payload]
    NovelService.delete_novel(params[:id], auth_payload['id'])
    render status: :ok, json: {}
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end
end
