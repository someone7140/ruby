# frozen_string_literal: true

module Mail
  # SendGrid送信用クラス
  class SendGrid
    def initialize(settings)
      @settings = settings
    end

    def deliver!(mail)
      from = ::SendGrid::Email.new(email: mail.from.first, name: 'HELCOM')
      to = ::SendGrid::Email.new(email: mail.to.first)
      subject = mail.subject
      content = ::SendGrid::Content.new(type: 'text/plain', value: mail.body.raw_source)
      sg_mail = ::SendGrid::Mail.new(from, subject, to, content)

      sg = ::SendGrid::API.new(api_key: @settings[:api_key])
      response = sg.client.mail._('send').post(request_body: sg_mail.to_json)
      status = response.status_code
      if !status == ResponseConstants::HTTP_STATUS_200 &&
         !status == ResponseConstants::HTTP_STATUS_202
        raise 'Send Failed'
      end
    end
  end
end
