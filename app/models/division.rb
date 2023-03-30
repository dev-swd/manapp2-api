class Division < ApplicationRecord
  belongs_to :department
  has_many :users, dependent: :nullify
  has_many :approvalauths, dependent: :destroy
end
