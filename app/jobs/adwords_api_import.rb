class AdwordsApiImport < ApplicationJob
  queue_as :default

  # Basic Operations Samples
  # https://developers.google.com/adwords/api/docs/samples/ruby/basic-operations

  def perform
    get_campaigns
    Campaign.find_each do |campaign|
      get_ad_groups(campaign.id)
    end
  end

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
        :number_results => PAGE_SIZE,
      }
    }

    # Set initial values.
    offset, page = 0, {}

    begin
      page = campaign_srv.get(selector)
      if page[:entries]
        page[:entries].each do |campaign|
          ActiveRecord::Base.transaction do
            Campaign.new do |cp|
              cp.adwords_id = campaign[:id]
              cp.name = campaign[:name]
              cp.status = campaign[:status]
              cp.serving_status = campaign[:serving_status]
              cp.start_date = campaign[:start_date]
              cp.end_date = campaign[:end_date]
              cp.save!
              cp.create_conf!(data: JSON.dump(campaign[:settings]))
            end
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
        :number_results => PAGE_SIZE,
      }
    }

    # Set initial values.
    offset, page = 0, {}

    begin
      page = ad_group_srv.get(selector)
      if page[:entries]
        page[:entries].each do |ad_group|
          ActiveRecord::Base.transaction do
            Adgroup.new do |ag|
              ag.adwords_id = ad_group[:id]
              ag.campaign_id = campaign_id
              ag.name = ad_group[:name]
              ag.status = ad_group[:status]
              ag.save!
              ag.create_conf!(data: JSON.dump(ad_group[:settings]))
            end
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
end