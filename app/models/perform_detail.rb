class PerformDetail < ApplicationRecord
  belongs_to :performance
  has_many :perform_denpyos, dependent: :destroy
  validates :description,  presence: true
end
