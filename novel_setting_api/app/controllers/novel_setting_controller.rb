# frozen_string_literal: true

# 小説設定に関わるコントローラー
class NovelSettingController < ApplicationController
  before_action :login_check

  # 設定作成
  def create_setting
    param! :novel_id, String, required: true, blank: false
    param! :name, String, required: true, blank: false
    param! :order, Integer, required: true

    auth_payload = session[:auth_payload]
    NovelSettingService.create_setting(auth_payload['id'], params[:novel_id], params[:name], params[:order])
    render status: :ok, json: {}
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end

  # 設定名称変更
  def update_setting_name
    param! :id, String, required: true, blank: false
    param! :name, String, required: true, blank: false

    auth_payload = session[:auth_payload]
    NovelSettingService.update_setting_name(params[:id], auth_payload['id'], params[:name])
    render status: :ok, json: {}
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end

  # 設定リスト取得
  def setting_list
    param! :novel_id, String, required: true, blank: false

    render status: :ok, json: {}
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end
end
