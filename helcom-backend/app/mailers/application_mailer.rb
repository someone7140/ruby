# frozen_string_literal: true

# ApplicationMailer
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'

  def mailer(email, title, body)
    mail(
      to: email,
      from: Rails.application.config.helcom.send_grid_from,
      subject: title,
      body: body
    )
  end
end
