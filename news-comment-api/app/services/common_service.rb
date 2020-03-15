require 'securerandom'

module CommonService

  module_function

  def generateUid
    SecureRandom.hex(8)
  end

  def generateToken
    SecureRandom.hex(16)
  end
end

