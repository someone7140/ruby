module MailSendUtil

  module_function

  def sendAuthMail(email, userId, token)
    urlLink = MailConstants::MAIL_LINK_DOMAIN +
      "auth/email_auth?user_id=" + userId +
      "&token=" + token +
      "&auth_purpose=" + UserConstants::MAIL_AUTH_PURPOSE_REGSITER
    body = "下記のURLよりユーザ登録を行ってください。有効期限は1日です。\r\n\r\n"
    body += urlLink
    sendMail(email, "ranknessユーザ登録", body)
  end

  def sendEmailChangeMail(email, userId, token)
    urlLink = MailConstants::MAIL_LINK_DOMAIN +
      "auth/email_auth?user_id=" + userId +
      "&token=" + token +
      "&auth_purpose=" + UserConstants::MAIL_AUTH_PURPOSE_CHANGE
    body = "下記のURLより変更処理を行ってください。有効期限は1日です。\r\n\r\n"
    body += urlLink
    sendMail(email, "ranknessメールアドレス変更", body)
  end

  def sendMail(email, title, body)
    begin
      mailSend = ActionMailer::Base.mail(
        to: email,
        from: MailConstants::SEND_GRID_FROM,
        subject: title,
        body: body
      ).deliver_now
      !mailSend.nil?
    rescue => e
      ExceptionUtil::exceptionHandling(e, ResponseConstants::HTTP_STATUS_500)
      false
    end
  end

  private_class_method :sendMail

end
