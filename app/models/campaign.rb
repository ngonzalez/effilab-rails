class Campaign < ActiveRecord::Base
  has_one :conf, class_name: "Config", as: :record

  has_many :adgroups
end
