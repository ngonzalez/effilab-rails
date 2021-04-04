class Campaign < ActiveRecord::Base
  has_one :conf, class_name: "Config", as: :record, dependent: :destroy

  has_many :ad_groups
end
