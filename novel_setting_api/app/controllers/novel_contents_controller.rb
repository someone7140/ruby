# frozen_string_literal: true

# 小説の内容に関わるコントローラー
class NovelContentsController < ApplicationController
  before_action :login_check

  # 内容更新
  def update_contents
    param! :contentId, String, required: true, blank: false
    param! :contentRecords, Array
    param! :contentHeadlines, Array

    auth_payload = session[:auth_payload]
    NovelContentsService.update_contents(params[:contentId], auth_payload['id'], params[:contentRecords],
                                         params[:contentHeadlines])
    render status: :ok, json: {}
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end

  # 内容取得
  def contents_by_novel_id
    param! :novelId, String, required: true, blank: false

    auth_payload = session[:auth_payload]
    contents = NovelContentsService.get_contens_by_novel_id(params[:novelId], auth_payload['id'])
    render status: :ok, json: contents
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end
end
