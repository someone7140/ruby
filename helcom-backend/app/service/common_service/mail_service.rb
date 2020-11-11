# frozen_string_literal: true

module CommonService
  # メール送信用のサービス
  class MailService
    include MasterConstants

    # email登録認証用メールの送信
    def self.send_email_regist_mail(user_id, email, token, category)
      url_link = Rails.application.config.helcom.mail_link_domain +
                 '/auth/mail/mail_regist_auth?user_id=' + user_id +
                 '&token=' + token + '&category=' + category
      body = if category == 'regist'
               "下記のURLよりユーザ登録を行ってください。有効期限は1日です。\r\n\r\n"
             else
               "下記のURLよりメールアドレス変更手続きを行ってください。有効期限は1日です。\r\n\r\n"
             end
      body += url_link
      ApplicationMailer.mailer(email, category == 'regist' ? 'helcomユーザ登録' : 'helcomメールドレス変更', body).deliver_now
    end

    # パスワードリセット登録用メールの送信
    def self.password_reset_regist_mail(user_id, email, token)
      url_link = Rails.application.config.helcom.mail_link_domain +
                 '/auth/mail/password_reset_regist?user_id=' + user_id +
                 '&token=' + token
      body = "下記のURLよりパスワード登録を行ってください。有効期限は1日です。\r\n\r\n"
      body += url_link
      ApplicationMailer.mailer(email, 'helcomパスワードリセット', body).deliver_now
    end

    # 問合せメールの送信
    def self.inquiry_mail(user_id, inquiry_category, title, contents)
      category = INQUIRY_CATEGORY_LIST.find { |i| i[:key] == inquiry_category }
      body = "【問合せユーザID】\r\n"
      body += user_id + "\r\n\r\n"
      body += "【問合せカテゴリー】\r\n"
      body += category.nil? ? '' : category[:value] + "\r\n\r\n"
      body += "【件名】\r\n"
      body += title + "\r\n\r\n"
      body += "【内容】\r\n"
      body += contents
      ApplicationMailer.mailer(Rails.application.config.helcom.inquiry_mail_address, 'helcom問合せ', body).deliver_now
    end
  end
end
