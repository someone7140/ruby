# frozen_string_literal: true

require 'jwt'
require 'securerandom'

# 共通的なサービス
class CommonService
  # uidの生成
  def self.generate_uid
    SecureRandom.uuid
  end

  # jwtのエンコード
  def self.encode_jwt(payload, exp)
    JWT.encode payload.merge({ exp: }), ENV.fetch('HMAC_SECRET'), 'HS256'
  end

  # jwtのデコード
  def self.decode_jwt(token)
    results = JWT.decode token, ENV.fetch('HMAC_SECRET'), true, { algorithm: 'HS256' }
    results[0]
  end
end
