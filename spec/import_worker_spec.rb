require 'rails_helper'
require 'spec_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe ImportWorker, type: :worker do
  let(:adwords) { AdwordsApi::Api.new(File.join(Rails.root, 'spec', 'adwords_api.yml')) }
  describe 'testing worker' do
    it 'ActionItemWorker jobs are enqueued in the scheduled queue' do
      described_class.perform_async
      assert_equal :default, described_class.queue
    end
    it 'goes into the jobs array for testing environment' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).by(1)
    end
  end
end
