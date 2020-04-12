Koala.configure do |config|
  config.app_id = ENV.fetch('FACEBOOK_API_ID')
  config.app_secret = ENV.fetch('FACEBOOK_SECRET')
  config.api_version = "v3.0"
end