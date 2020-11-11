# frozen_string_literal: true

require 'mail/send_grid'

ActionMailer::Base.add_delivery_method :sendgrid,
                                       Mail::SendGrid,
                                       api_key: Rails.application.config.helcom.send_grid_api_key
