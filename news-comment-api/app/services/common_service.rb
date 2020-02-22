require 'securerandom'

module CommonService

  module_function

  def generateUid
    SecureRandom.hex(8)
  end

end

