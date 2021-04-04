class CreateAdGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :ad_groups do |t|
      t.integer :campaign_id
      t.text :adwords_id
      t.text :adwords_campaign_id
      t.text :name
      t.text :status
      t.datetime :created_at
      t.datetime :updated_at
      t.index [:campaign_id], name: :index_ad_groups_on_campaign_id
      t.index [:adwords_id], name: :index_ad_groups_on_adwords_id
    end
  end
end
