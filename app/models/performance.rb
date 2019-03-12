class Performance < ApplicationRecord
  belongs_to :user
  has_many :perform_details, dependent: :destroy
  has_many :perform_denpyos, dependent: :destroy
  validates :name,  presence: true
  mount_uploader :k_pic, PictureUploader
end
