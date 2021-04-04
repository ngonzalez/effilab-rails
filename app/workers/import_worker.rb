require 'adwords_api'

class ImportWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :default, :retry => true, :backtrace => true

  # Basic Operations Samples
  # https://developers.google.com/adwords/api/docs/samples/ruby/basic-operations

  API_VERSION = :v201809
  PAGE_SIZE = 500

  attr_accessor :adwords

  def perform
    set_adwords
    get_campaigns

    Campaign.find_each do |campaign|
      get_ad_groups(campaign)
    end
  rescue AdsCommon::Errors::OAuth2VerificationRequired => exception
    Rails.logger.error exception
  end

  def set_adwords
    # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
    # when called without parameters.
    @adwords = AdwordsApi::Api.new

    # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
    # the configuration file or provide your own logger:
    adwords.logger = ActiveSupport::Logger.new(ENV['LOG_FILE_PATH'])
  end

  def get_campaigns
    campaign_srv = adwords.service(:CampaignService, API_VERSION)

    # Get all the campaigns for this account.
    selector = {
      :fields => ['Id', 'Name', 'Status', 'ServingStatus', 'StartDate', 'EndDate', 'Settings'],
      :ordering => [
        {:field => 'Id', :sort_order => 'ASCENDING'}
      ],
      :paging => {
        :start_index => 0,
        :number_results => PAGE_SIZE,
      }
    }

    # Set initial values.
    offset, page = 0, {}

    begin
      page = campaign_srv.get(selector)
      if page[:entries]
        page[:entries].each do |item|
          begin
            ActiveRecord::Base.transaction do
              campaign = Campaign.find_by(adwords_id: item[:id]) || Campaign.new(adwords_id: item[:id])
              campaign.name = item[:name]
              campaign.status = item[:status]
              campaign.serving_status = item[:serving_status]
              campaign.start_date = item[:start_date]
              campaign.end_date = item[:end_date]
              campaign.save!
              campaign.build_conf if !campaign.conf
              campaign.conf.update!(data: JSON.dump(item[:settings]))
            end
          rescue => _exception
            Rails.logger.error _exception
            next
          end
        end
        # Increment values to request the next page.
        offset += PAGE_SIZE
        selector[:paging][:start_index] = offset
      end
    end while page[:total_num_entries] > offset
  end

  def get_ad_groups(campaign)
    ad_group_srv = adwords.service(:AdGroupService, API_VERSION)

    # Get all the ad groups for this campaign.
    selector = {
      :fields => ['Id', 'Name', 'CampaignId', 'Status', 'Settings'],
      :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}],
      :predicates => [
        {:field => 'CampaignId', :operator => 'IN', :values => [campaign.adwords_id]}
      ],
      :paging => {
        :start_index => 0,
        :number_results => PAGE_SIZE,
      }
    }

    # Set initial values.
    offset, page = 0, {}

    begin
      page = ad_group_srv.get(selector)
      if page[:entries]
        page[:entries].each do |item|
          begin
            ActiveRecord::Base.transaction do
              ad_group = AdGroup.find_by(adwords_id: item[:id]) || AdGroup.new(adwords_id: item[:id])
              ad_group.campaign_id = campaign.id
              ad_group.name = ad_group[:name]
              ad_group.status = ad_group[:status]
              ad_group.save!
              ad_group.build_conf if !ad_group.conf
              ad_group.conf.update!(data: JSON.dump(item[:settings]))
            end
          rescue => _exception
            Rails.logger.error _exception
            next
          end
        end
        # Increment values to request the next page.
        offset += PAGE_SIZE
        selector[:paging][:start_index] = offset
      end
    end while page[:total_num_entries] > offset
  end
end