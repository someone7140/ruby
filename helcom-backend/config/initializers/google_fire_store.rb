# frozen_string_literal: true

require 'google/cloud/firestore'

Google::Cloud::Firestore.configure do |config|
  config.credentials = Rails.application.config.helcom.firebase_credential_path
end
