# frozen_string_literal: true

require 'securerandom'

module CommonService
  # 各種値の生成サービス
  class GenerateService
    def self.generate_token(length)
      SecureRandom.hex(length)
    end
  end
end
