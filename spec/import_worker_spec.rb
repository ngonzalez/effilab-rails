require 'rails_helper'
require 'spec_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe ImportWorker, type: :worker do
  let(:adwords) { AdwordsApi::Api.new(File.join(Rails.root, 'spec', 'fixtures', 'adwords_api.yml')) }
  describe 'testing worker' do
    it 'jobs are sent to default queue' do
      described_class.perform_async
      assert_equal :default, described_class.queue
    end
    it 'enqueue jobs' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).by(1)
    end
    it 'get adwords campaigns' do
      expect do
        worker = described_class.new
        adwords = double('adwords')
        service = double('service')
        expect(service).to receive(:get).and_return(YAML.load(File.read('spec/fixtures/campaign_pages.yml')))
        expect(adwords).to receive(:service).with(:CampaignService, described_class::API_VERSION).and_return(service)
        worker.adwords = adwords
        worker.get_campaigns
      end.to change{ Campaign.count }.from(0).to(64)
    end
    it 'get adwords ad_groups' do
      expect do
        worker = described_class.new
        adwords = double('adwords')
        service = double('service')
        expect(service).to receive(:get).and_return(YAML.load(File.read('spec/fixtures/ad_group_pages.yml')))
        expect(adwords).to receive(:service).with(:AdGroupService, described_class::API_VERSION).and_return(service)
        campaign = Campaign.create!(adwords_id: '443336848', name: 'Test Campaign')
        worker.adwords = adwords
        worker.get_ad_groups(campaign)
      end.to change{ AdGroup.count }.from(0).to(100)
    end
  end
end
