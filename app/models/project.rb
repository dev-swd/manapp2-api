class Project < ApplicationRecord
  has_many :risks, dependent: :destroy
  has_many :qualitygoals, dependent: :destroy
  has_many :members, dependent: :destroy
  has_many :phases, dependent: :destroy
  has_one :report, dependent: :destroy
end
