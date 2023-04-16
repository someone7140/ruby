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
  rescue StandardError => e
    render status: :internal_server_error, json: { message: e }
  end
end
