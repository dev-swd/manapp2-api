class Applicationrole < ApplicationRecord
  has_many :applications, dependent: :destroy
end
