class Hospital < ApplicationRecord
  belongs_to :company
  belongs_to :user
  has_many :file_managers
end
