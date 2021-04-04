require "adwords_api"
require "oauth2"

namespace :adwords_api do
  desc 'Setup Adwords API configuration file'
  task setup: :environment do
    # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
    # when called without parameters.
    @adwords = AdwordsApi::Api.new

    # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
    # the configuration file or provide your own logger:
    @adwords.logger = ActiveSupport::Logger.new(ENV['LOG_FILE_PATH'])

    # You can call authorize explicitly to obtain the access token. Otherwise, it
    # will be invoked automatically on the first API call.
    # There are two ways to provide verification code, first one is via the block:
    verification_code = nil
    token = @adwords.authorize() do |auth_url|
      puts "Hit Auth error, please navigate to URL:\n\t%s" % auth_url
      print 'log in and type the verification code: '
      verification_code = STDIN.gets.chomp
      verification_code
    end
    if verification_code && token
      @adwords.save_oauth2_token(token)
      puts 'Authentication token is now saved and will be automatically used by the application'
    end
  rescue => exception
    Rails.logger.error exception
  end

  desc 'Import Campaigns and AdGroups into database'
  task import: :environment do
    begin
      ImportWorker.perform_async
    rescue AdsCommon::Errors::OAuth2VerificationRequired => _exception
      puts "Please authenticate with rake adwords_api:setup"
    end
  end

  desc 'Process AdWords data'
  task process: :environment do
    stats = {nb_ad_groups: 0, nb_campaigns: Campaign.count}

    Campaign.find_each do |campaign|
      nb_adg = campaign.ad_groups.count
      stats[:nb_ad_groups] += nb_adg

      Rails.logger.info "Campaign: %{id} \"%{name}\" [%{status}] AdGroups:%{nb_adg}" % {
        id: campaign.adwords_id,
        name: campaign.name,
        status: campaign.status,
        nb_adg: nb_adg,
      }

      campaign.ad_groups.each do |ad_group|
        Rails.logger.info "Adgroup: %{id} \"%{name}\" [%{status}]" % {
          id: ad_group.adwords_id,
          name: ad_group.name,
          status: ad_group.status,
        }
      end
    end

    return unless Campaign.any?

    Rails.logger.info "Mean number of AdGroups per Campaign: #{stats[:nb_ad_groups]/stats[:nb_campaigns]}"
  rescue => exception
    Rails.logger.error exception
  end
end
