class AdGroup < ActiveRecord::Base
  belongs_to :campaign

  has_one :conf, class_name: "Config", as: :record, dependent: :destroy
end
