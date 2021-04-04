require "adwords_api"

namespace :adwords_api do
  desc 'Adwords API'
  task setup: :environment do
    @adwords = AdwordsApi::Api.new

    # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
    # the configuration file or provide your own logger:
    adwords.logger = ActiveSupport::Logger.new(ENV['LOG_FILE_PATH'])

    # You can call authorize explicitly to obtain the access token. Otherwise, it
    # will be invoked automatically on the first API call.
    # There are two ways to provide verification code, first one is via the block:
    verification_code = nil
    token = @adwords.authorize() do |auth_url|
      puts "Hit Auth error, please navigate to URL:\n\t%s" % auth_url
      print 'log in and type the verification code: '
      verification_code = gets.chomp
      verification_code
    end
    if verification_code && token
      puts 'Updating adwords_api.yml with OAuth credentials.'
      @adwords.save_oauth2_token(token)
      puts 'OAuth2 token is now saved and will be automatically used by the library.'
      puts 'Please restart the script now.'
    end
  end
end
