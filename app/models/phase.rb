class Phase < ApplicationRecord
  belongs_to :project
  has_many :tasks, dependent: :destroy
end