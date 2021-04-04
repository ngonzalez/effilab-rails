class CreateCampaigns < ActiveRecord::Migration[6.1]
  def change
    create_table :campaigns do |t|
      t.text :adwords_id
      t.text :name
      t.text :status
      t.text :serving_status
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :created_at
      t.datetime :updated_at
      t.index [:adwords_id], name: :index_campaigns_on_adwords_id, unique: true
    end
  end
end
