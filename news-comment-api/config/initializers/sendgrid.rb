require 'mail/send_grid'

ActionMailer::Base.add_delivery_method :sendgrid, Mail::SendGrid, api_key: Rails.application.config.rankness.sendGridApiKey
