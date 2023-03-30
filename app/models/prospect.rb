class Prospect < ApplicationRecord
  has_many :leadlogs, dependent: :destroy
  has_many :salesreports, dependent: :destroy
end
