# frozen_string_literal: true

# 小説設定に関わるコントローラー
class NovelSettingController < ApplicationController
  before_action :login_check

  # 設定作成
  def create_setting
    param! :novelId, String, required: true, blank: false
    param! :name, String, required: true, blank: false
    param! :order, Integer, required: true

    auth_payload = session[:auth_payload]
    NovelSettingService.create_setting(auth_payload['id'], params[:novelId], params[:name], params[:order])
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

  # 設定内容を更新
  def update_settings
    param! :id, String, required: true, blank: false
    param! :settings, Array

    auth_payload = session[:auth_payload]
    NovelSettingService.update_settings(params[:id], auth_payload['id'], params[:settings])
    render status: :ok, json: {}
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end

  # 設定リスト取得
  def setting_list
    param! :novelId, String, required: true, blank: false

    auth_payload = session[:auth_payload]
    result = NovelSettingService.setting_list(auth_payload['id'], params[:novelId])
    render status: :ok, json: result
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end

  # ID指定で設定取得
  def setting_by_id
    param! :id, String, required: true, blank: false
    param! :novelId, String, required: true, blank: false

    auth_payload = session[:auth_payload]
    result = NovelSettingService.setting_by_id(params[:id], auth_payload['id'], params[:novelId])
    render status: :ok, json: result
  rescue InvalidParameterError => e
    render status: :bad_request, json: { message: e }
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end
end
