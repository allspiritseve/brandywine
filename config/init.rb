require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, :development)

Dotenv.load

Time.zone = "America/Detroit"
ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.default_timezone = "America/Detroit"

Twitter.configure do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end
