# frozen_string_literal: true

module Common
  # 問合せに関わるコントローラー
  class InquiryController < ApplicationController
    include CommonService
    include ResponseConstants

    before_action :logged_in_user

    # 問合せメールの送信
    def send_inquiry
      MailService.inquiry_mail(
        session[:user_id],
        send_inquiry_param[:inquiry_category],
        send_inquiry_param[:title],
        send_inquiry_param[:contents]
      )
      render json: { status: HTTP_STATUS_200 }
    rescue => e
      puts e
      render json: { status: HTTP_STATUS_500 }
    end

    def send_inquiry_param
      params.require(:send_inquiry).permit(:inquiry_category, :title, :contents)
    end
  end
end
