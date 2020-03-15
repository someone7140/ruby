SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: true,
    samesite: {
      none: true
    }
  }
end
