class Adgroup < ActiveRecord::Base
  belongs_to :campaign

  has_one :conf, class_name: "Config", as: :record
end
