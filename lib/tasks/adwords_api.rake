require "adwords_api"
require "oauth2"

API_VERSION = :v201809
PAGE_SIZE = 500

namespace :adwords_api do
  desc 'Setup Adwords API configuration file'
  task setup: :environment do
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
      puts 'Updating adwords_api.yml with OAuth credentials.'
      @adwords.save_oauth2_token(token)
      puts 'OAuth2 token is now saved and will be automatically used by the library.'
      puts 'Please restart the script now.'
    end
  end

  desc 'Import Campaigns and AdGroups into database'
  task import: :environment do
    # Basic Operations Samples
    # https://developers.google.com/adwords/api/docs/samples/ruby/basic-operations
    @adwords = AdwordsApi::Api.new

    # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
    # the configuration file or provide your own logger:
    @adwords.logger = ActiveSupport::Logger.new(ENV['LOG_FILE_PATH'])

    def get_campaigns
      campaign_srv = @adwords.service(:CampaignService, API_VERSION)

      # Get all the campaigns for this account.
      selector = {
        :fields => ['Id', 'Name', 'Status', 'ServingStatus', 'StartDate', 'EndDate', 'Settings'],
        :ordering => [
          {:field => 'Id', :sort_order => 'ASCENDING'}
        ],
        :paging => {
          :start_index => 0,
          :number_results => PAGE_SIZE
        }
      }

      # Set initial values.
      offset, page = 0, {}

      begin
        page = campaign_srv.get(selector)
        if page[:entries]
          page[:entries].each do |campaign|
            # New transaction
            Campaign.new do |cp|
              cp.adwords_id = campaign[:id]
              cp.name = campaign[:name]
              cp.status = campaign[:status]
              cp.serving_status = campaign[:serving_status]
              cp.start_date = campaign[:start_date]
              cp.end_date = campaign[:end_date]
              cp.save
              cp.create_conf(data: JSON.dump(campaign[:settings]))
            end
          end
          # Increment values to request the next page.
          offset += PAGE_SIZE
          selector[:paging][:start_index] = offset
        end
      rescue => exception
        @adwords.logger.error exception.inspect
      end while page[:total_num_entries] > offset
    end

    def get_ad_groups(campaign_id)

      ad_group_srv = @adwords.service(:AdGroupService, API_VERSION)

      # Get all the ad groups for this campaign.
      selector = {
        :fields => ['Id', 'Name', 'CampaignId', 'Status', 'Settings'],
        :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}],
        :predicates => [
          {:field => 'CampaignId', :operator => 'IN', :values => [campaign_id]}
        ],
        :paging => {
          :start_index => 0,
          :number_results => PAGE_SIZE
        }
      }

      # Set initial values.
      offset, page = 0, {}

      begin
        page = ad_group_srv.get(selector)
        if page[:entries]
          page[:entries].each do |ad_group|
            # New transaction
            Adgroup.new do |ag|
              ag.adwords_id = ad_group[:id]
              ag.campaign = Campaign.find_by(adwords_id: campaign_id)
              ag.name = ad_group[:name]
              ag.status = ad_group[:status]
              ag.save
              ag.create_conf(data: JSON.dump(ad_group[:settings]))
            end
          end
          # Increment values to request the next page.
          offset += PAGE_SIZE
          selector[:paging][:start_index] = offset
        end
      rescue => exception
        @adwords.logger.error exception.inspect
      end while page[:total_num_entries] > offset
    end

    get_campaigns

    Campaign.find_each do |campaign|
      get_ad_groups(campaign.id)
    end
  end

  desc 'Process AdWords data'
  task process: :environment do
    stats = {nb_ad_groups: 0, nb_campaigns: Campaign.count}

    Campaign.find_each do |campaign|
      nb_adg = campaign.adgroups.count
      stats[:nb_ad_groups] += nb_adg

      @logger.info "Campaign: %{id} \"%{name}\" [%{status}] AdGroups:%{nb_adg}" % {
        id: campaign.adwords_id,
        name: campaign.name,
        status: campaign.status,
        nb_adg: nb_adg,
      }

      campaign.adgroups.each do |adgroup|
        @logger.info "Adgroup: %{id} \"%{name}\" [%{status}]" % {
          id: adgroup.adwords_id,
          name: adgroup.name,
          status: adgroup.status,
        }
      end
    end

    return unless Campaign.any?

    @logger.info "Mean number of AdGroups per Campaign: #{stats[:nb_ad_groups]/stats[:nb_campaigns]}"
  end
end
